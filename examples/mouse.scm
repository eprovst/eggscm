(import eggscm)

(define (setup)
  (window-title! "Mouse Demo")
  (background! (rgb 0 0 0))
  (color! (rgb 1 0 0)))

(define (draw)
  (when (mouse-down?)
    (pixel! (mouse))))

(sketch setup draw)
