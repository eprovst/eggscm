(import eggscm)

; The GLXOESFTTPSV quadratic map
(define (quadmap p)
  (let-values (((x y) (crds p)))
    (pt (+ -0.6 (* -0.1 x) (* 1.1 x x) (* 0.2 x y) (* -0.8 y) (* 0.6 y y))
        (+ -0.7 (*  0.7 x) (* 0.7 x x) (* 0.3 x y) (*  0.6 y) (* 0.9 y y)))))

(define (setup)
  (window-title! "GLXOESFTTPSV")
  (frame-rate! 30)
  (size! 512 512)
  (background! (hsb 4 1 0.05))
  (color! (hsb 4 1 1))
  (origin! 'center)
  (scale! (/ (width) 2) (/ (height) -2))
  (set! p (pt 0 0)))

(define (loop)
  (repeat 100
    (set! p (quadmap p))
    (pixel! p))
  (when (> (frame-count) 100)
    (loop! #f)))

(sketch setup loop)
