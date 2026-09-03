import { type SVGProps } from "react"

export interface AndroidProps extends SVGProps<SVGSVGElement> {
  src?: string
  videoSrc?: string
  poster?: string
  alt?: string
}

// Écran natif 360×800 à l'intérieur du cadre : préparer les captures à ce ratio (9:20).
export function Android({
  src,
  videoSrc,
  poster,
  alt = "",
  ...props
}: AndroidProps) {
  const clip = `android-clip-${src ?? videoSrc ?? "empty"}`.replace(/[^a-z0-9-]/gi, "-")
  return (
    <svg
      viewBox="0 0 380 830"
      width="100%"
      fill="none"
      role={alt ? "img" : "presentation"}
      aria-label={alt || undefined}
      xmlns="http://www.w3.org/2000/svg"
      {...props}
    >
      <path d="M376 153H378C379.105 153 380 153.895 380 155V249C380 250.105 379.105 251 378 251H376V153Z" fill="#3a3a42" />
      <path d="M376 301H378C379.105 301 380 301.895 380 303V351C380 352.105 379.105 353 378 353H376V301Z" fill="#3a3a42" />
      <path
        d="M0 42C0 18.8041 18.804 0 42 0H336C359.196 0 378 18.804 378 42V788C378 811.196 359.196 830 336 830H42C18.804 830 0 811.196 0 788V42Z"
        fill="#26262e"
      />
      <path
        d="M2 43C2 22.0132 19.0132 5 40 5H338C358.987 5 376 22.0132 376 43V787C376 807.987 358.987 825 338 825H40C19.0132 825 2 807.987 2 787V43Z"
        fill="#0b0b0c"
      />
      <rect x="9" y="14" width="360" height="800" rx="33" ry="25" fill="#fafaf9" />
      {src && (
        <image
          href={src}
          x="9"
          y="14"
          width="360"
          height="800"
          preserveAspectRatio="xMidYMid slice"
          clipPath={`url(#${clip})`}
        />
      )}
      {videoSrc && (
        <foreignObject x="9" y="14" width="360" height="800" clipPath={`url(#${clip})`}>
          <video className="size-full object-cover" src={videoSrc} poster={poster} autoPlay loop muted playsInline preload="none" />
        </foreignObject>
      )}
      <circle cx="189" cy="28" r="9" fill="#0b0b0c" />
      <circle cx="189" cy="28" r="4" fill="#1c1c21" />
      <defs>
        <clipPath id={clip}>
          <rect x="9" y="14" width="360" height="800" rx="33" ry="25" />
        </clipPath>
      </defs>
    </svg>
  )
}
