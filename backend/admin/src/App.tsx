import { FormEvent, useCallback, useEffect, useState } from 'react';
import {
  BadgeCheck,
  Building2,
  Check,
  ClipboardCheck,
  LogOut,
  MessageSquareWarning,
  RefreshCw,
  ShieldCheck,
  Star,
  X,
} from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Separator } from '@/components/ui/separator';
import { Skeleton } from '@/components/ui/skeleton';
import { Textarea } from '@/components/ui/textarea';
import { cn } from '@/lib/utils';

type Verification = {
  id: string;
  kind: 'INDIVIDUAL' | 'AGENCY';
  name: string;
  phone: string;
  whatsapp: string | null;
  coverage: string[];
  updatedAt: string;
};

type Review = {
  id: string;
  rating: number;
  comment: string | null;
  reportedReason: string | null;
  brokerReply: string | null;
  createdAt: string;
  broker: { id: string; name: string };
};

type Queue = { verifications: Verification[]; reviews: Review[] };
type Section = 'verifications' | 'reviews';

const storageKey = 'wk-admin-token';

export function App() {
  const [token, setToken] = useState(() => sessionStorage.getItem(storageKey));

  if (!token) {
    return (
      <Login
        onAuthenticated={(next) => {
          sessionStorage.setItem(storageKey, next);
          setToken(next);
        }}
      />
    );
  }

  return (
    <Dashboard
      token={token}
      onLogout={() => {
        sessionStorage.removeItem(storageKey);
        setToken(null);
      }}
    />
  );
}

function Login({ onAuthenticated }: { onAuthenticated: (token: string) => void }) {
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setBusy(true);
    setError('');
    const data = new FormData(event.currentTarget);
    try {
      const response = await fetch('/admin-api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: data.get('email'), password: data.get('password') }),
      });
      if (!response.ok)
        throw new Error(
          response.status === 429
            ? 'Trop de tentatives. Réessayez dans cinq minutes.'
            : 'E-mail ou mot de passe incorrect.',
        );
      const body = (await response.json()) as { accessToken: string };
      onAuthenticated(body.accessToken);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Connexion impossible.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="grid min-h-svh lg:grid-cols-[minmax(22rem,0.85fr)_1.15fr]">
      <section className="hidden bg-primary p-12 text-primary-foreground lg:flex lg:flex-col lg:justify-between">
        <Brand inverse />
        <div className="max-w-md space-y-4">
          <ShieldCheck className="size-10" aria-hidden="true" />
          <h1 className="text-4xl font-semibold tracking-tight">La confiance se décide ici.</h1>
          <p className="text-lg text-primary-foreground/75">
            Vérifiez les professionnels et protégez les avis publiés sur Woutalma Keur.
          </p>
        </div>
        <p className="text-sm text-primary-foreground/60">Accès réservé aux modérateurs</p>
      </section>
      <section className="flex items-center justify-center p-5 sm:p-10">
        <div className="w-full max-w-sm space-y-8">
          <div className="lg:hidden">
            <Brand />
          </div>
          <div className="space-y-2">
            <h2 className="text-3xl font-semibold tracking-tight">Connexion</h2>
            <p className="text-muted-foreground">Ouvrez la file de modération.</p>
          </div>
          <form className="space-y-5" onSubmit={submit}>
            <div className="space-y-2">
              <Label htmlFor="email">E-mail administrateur</Label>
              <Input
                id="email"
                name="email"
                type="email"
                autoComplete="username"
                required
                className="h-12 bg-card"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Mot de passe</Label>
              <Input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                minLength={12}
                required
                className="h-12 bg-card"
              />
            </div>
            {error && (
              <p role="alert" className="flex gap-2 text-sm text-destructive">
                <X className="mt-0.5 size-4 shrink-0" />
                {error}
              </p>
            )}
            <Button
              type="submit"
              size="lg"
              className="h-12 w-full text-base"
              disabled={busy}
              aria-busy={busy}
            >
              {busy ? (
                <>
                  <RefreshCw className="animate-spin" /> Connexion…
                </>
              ) : (
                <>
                  <ShieldCheck /> Ouvrir la console
                </>
              )}
            </Button>
          </form>
        </div>
      </section>
    </main>
  );
}

function Dashboard({ token, onLogout }: { token: string; onLogout: () => void }) {
  const [queue, setQueue] = useState<Queue | null>(null);
  const [section, setSection] = useState<Section>('verifications');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [busy, setBusy] = useState('');
  const [rejecting, setRejecting] = useState('');
  const [reason, setReason] = useState('');

  const request = useCallback(
    async (path: string, init?: RequestInit) => {
      const response = await fetch(`/admin-api/${path}`, {
        ...init,
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}`, ...init?.headers },
      });
      if (response.status === 401 || response.status === 403) {
        onLogout();
        throw new Error('Votre session a expiré.');
      }
      if (!response.ok) throw new Error('La demande n’a pas abouti. Réessayez.');
      return response;
    },
    [onLogout, token],
  );

  const load = useCallback(async () => {
    setError('');
    try {
      const response = await request('queue');
      setQueue((await response.json()) as Queue);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Chargement impossible.');
    }
  }, [request]);

  useEffect(() => {
    void load();
  }, [load]);

  async function decide(path: string, body: object, success: string) {
    setBusy(path);
    setError('');
    try {
      await request(path, { method: 'PATCH', body: JSON.stringify(body) });
      setNotice(success);
      setRejecting('');
      setReason('');
      await load();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Action impossible.');
    } finally {
      setBusy('');
    }
  }

  const counts = { verifications: queue?.verifications.length ?? 0, reviews: queue?.reviews.length ?? 0 };

  return (
    <div className="min-h-svh lg:grid lg:grid-cols-[17rem_1fr]">
      <aside className="border-b bg-card p-5 lg:fixed lg:inset-y-0 lg:w-[17rem] lg:border-r lg:border-b-0 lg:p-6">
        <Brand />
        <nav aria-label="Files de modération" className="mt-6 flex gap-2 lg:mt-12 lg:flex-col">
          <NavButton
            active={section === 'verifications'}
            icon={BadgeCheck}
            label="Vérifications"
            count={counts.verifications}
            onClick={() => setSection('verifications')}
          />
          <NavButton
            active={section === 'reviews'}
            icon={MessageSquareWarning}
            label="Avis signalés"
            count={counts.reviews}
            onClick={() => setSection('reviews')}
          />
        </nav>
        <Button variant="ghost" className="mt-6 hidden w-full justify-start lg:flex" onClick={onLogout}>
          <LogOut /> Déconnexion
        </Button>
      </aside>

      <main className="p-5 sm:p-8 lg:col-start-2 lg:p-10">
        <div className="mx-auto max-w-5xl">
          <header className="flex items-start justify-between gap-4">
            <div>
              <p className="mb-2 text-sm font-semibold text-primary">MODÉRATION</p>
              <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">
                {section === 'verifications' ? 'Profils à vérifier' : 'Avis à examiner'}
              </h1>
              <p className="mt-2 text-muted-foreground">
                {section === 'verifications'
                  ? 'Décidez qui peut afficher le badge Vérifié.'
                  : 'Publiez ou retirez les avis en attente.'}
              </p>
            </div>
            <Button
              variant="outline"
              size="icon"
              className="size-11 bg-card"
              onClick={() => void load()}
              aria-label="Actualiser la file"
            >
              <RefreshCw />
            </Button>
          </header>

          <Separator className="my-8" />
          <div aria-live="polite" className="sr-only">
            {notice}
          </div>
          {error && (
            <Card className="mb-6 border-destructive/30 bg-destructive/5">
              <CardContent className="flex items-center gap-3 text-destructive">
                <X className="size-5" />
                {error}
              </CardContent>
            </Card>
          )}

          {!queue ? (
            <Loading />
          ) : section === 'verifications' ? (
            <div className="space-y-4">
              {queue.verifications.length === 0 ? (
                <Empty icon={ClipboardCheck} title="Aucun profil en attente" />
              ) : (
                queue.verifications.map((item) => (
                  <Card key={item.id}>
                    <CardHeader className="sm:grid-cols-[1fr_auto]">
                      <div className="flex gap-3">
                        <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-accent text-accent-foreground">
                          <Building2 className="size-5" />
                        </span>
                        <div>
                          <CardTitle className="text-lg">{item.name}</CardTitle>
                          <CardDescription>
                            {item.kind === 'AGENCY' ? 'Agence immobilière' : 'Courtier indépendant'} · demande
                            du {formatDate(item.updatedAt)}
                          </CardDescription>
                        </div>
                      </div>
                      <Badge variant="secondary" className="mt-3 sm:mt-0">
                        <BadgeCheck /> En attente
                      </Badge>
                    </CardHeader>
                    <CardContent className="space-y-5">
                      <dl className="grid gap-3 text-sm sm:grid-cols-2">
                        <div>
                          <dt className="text-muted-foreground">Téléphone</dt>
                          <dd className="font-medium">{item.phone}</dd>
                        </div>
                        <div>
                          <dt className="text-muted-foreground">Zone couverte</dt>
                          <dd className="font-medium">{item.coverage.join(', ') || 'Non renseignée'}</dd>
                        </div>
                      </dl>
                      {rejecting === item.id && (
                        <div className="space-y-2 rounded-xl bg-muted p-4">
                          <Label htmlFor={`reason-${item.id}`}>Pourquoi refusez-vous ce profil ?</Label>
                          <Textarea
                            id={`reason-${item.id}`}
                            value={reason}
                            onChange={(event) => setReason(event.target.value)}
                            maxLength={300}
                            placeholder="Motif visible par le courtier"
                          />
                          <p className="text-xs text-muted-foreground">{reason.length}/300</p>
                        </div>
                      )}
                      <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                        {rejecting === item.id ? (
                          <>
                            <Button
                              variant="ghost"
                              className="h-11"
                              onClick={() => {
                                setRejecting('');
                                setReason('');
                              }}
                            >
                              Annuler
                            </Button>
                            <Button
                              variant="destructive"
                              className="h-11"
                              disabled={!reason.trim() || !!busy}
                              onClick={() =>
                                void decide(
                                  `verifications/${item.id}`,
                                  { status: 'REJECTED', reason },
                                  'Profil refusé.',
                                )
                              }
                            >
                              <X /> Refuser ce profil
                            </Button>
                          </>
                        ) : (
                          <>
                            <Button variant="outline" className="h-11" onClick={() => setRejecting(item.id)}>
                              <X /> Refuser
                            </Button>
                            <Button
                              className="h-11"
                              disabled={!!busy}
                              onClick={() =>
                                void decide(
                                  `verifications/${item.id}`,
                                  { status: 'VERIFIED' },
                                  'Profil vérifié.',
                                )
                              }
                            >
                              <Check /> Approuver
                            </Button>
                          </>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          ) : (
            <div className="space-y-4">
              {queue.reviews.length === 0 ? (
                <Empty icon={ClipboardCheck} title="Aucun avis à examiner" />
              ) : (
                queue.reviews.map((item) => (
                  <Card key={item.id}>
                    <CardHeader>
                      <div className="flex items-start justify-between gap-4">
                        <div>
                          <CardTitle className="text-lg">Avis sur {item.broker.name}</CardTitle>
                          <CardDescription>Publié le {formatDate(item.createdAt)}</CardDescription>
                        </div>
                        <Badge variant="secondary">
                          <Star className="fill-current" /> {item.rating}/5
                        </Badge>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-5">
                      <blockquote className="border-l-2 border-primary pl-4 text-base">
                        {item.comment || 'Aucun commentaire écrit.'}
                      </blockquote>
                      {item.reportedReason && (
                        <div className="rounded-xl bg-muted p-4">
                          <p className="text-xs font-semibold text-muted-foreground">MOTIF DU SIGNALEMENT</p>
                          <p className="mt-1">{item.reportedReason}</p>
                        </div>
                      )}
                      {item.brokerReply && (
                        <p className="text-sm text-muted-foreground">
                          <span className="font-semibold text-foreground">Réponse du courtier :</span>{' '}
                          {item.brokerReply}
                        </p>
                      )}
                      <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                        <Button
                          variant="outline"
                          className="h-11 text-destructive"
                          disabled={!!busy}
                          onClick={() =>
                            void decide(`reviews/${item.id}`, { status: 'REJECTED' }, 'Avis retiré.')
                          }
                        >
                          <X /> Retirer
                        </Button>
                        <Button
                          className="h-11"
                          disabled={!!busy}
                          onClick={() =>
                            void decide(`reviews/${item.id}`, { status: 'PUBLISHED' }, 'Avis publié.')
                          }
                        >
                          <Check /> Publier
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

function Brand({ inverse = false }: { inverse?: boolean }) {
  return (
    <div className="flex items-center gap-3">
      <span
        className={cn(
          'flex size-10 items-center justify-center rounded-xl',
          inverse ? 'bg-white text-primary' : 'bg-primary text-primary-foreground',
        )}
      >
        <ShieldCheck className="size-5" />
      </span>
      <div>
        <p className="font-semibold leading-tight">Woutalma Keur</p>
        <p className={cn('text-xs', inverse ? 'text-primary-foreground/65' : 'text-muted-foreground')}>
          Console de modération
        </p>
      </div>
    </div>
  );
}

function NavButton({
  active,
  icon: Icon,
  label,
  count,
  onClick,
}: {
  active: boolean;
  icon: typeof BadgeCheck;
  label: string;
  count: number;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-current={active ? 'page' : undefined}
      className={cn(
        'flex min-h-11 flex-1 items-center gap-2 rounded-xl px-3 py-2 text-left text-sm font-medium transition-colors lg:flex-none',
        active
          ? 'bg-accent text-accent-foreground'
          : 'text-muted-foreground hover:bg-muted hover:text-foreground',
      )}
    >
      <Icon className="size-4" />
      <span className="truncate">{label}</span>
      <Badge variant={active ? 'default' : 'secondary'} className="ml-auto">
        {count}
      </Badge>
    </button>
  );
}

function Loading() {
  return (
    <div className="space-y-4" aria-label="Chargement">
      <Skeleton className="h-44 rounded-xl" />
      <Skeleton className="h-44 rounded-xl" />
    </div>
  );
}

function Empty({ icon: Icon, title }: { icon: typeof ClipboardCheck; title: string }) {
  return (
    <Card>
      <CardContent className="flex min-h-64 flex-col items-center justify-center gap-3 text-center">
        <span className="flex size-14 items-center justify-center rounded-2xl bg-accent text-accent-foreground">
          <Icon className="size-7" />
        </span>
        <h2 className="text-lg font-semibold">{title}</h2>
        <p className="max-w-sm text-sm text-muted-foreground">
          La file est à jour. Les nouvelles demandes apparaîtront ici.
        </p>
      </CardContent>
    </Card>
  );
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat('fr-SN', { dateStyle: 'medium' }).format(new Date(value));
}
