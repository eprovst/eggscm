(import eggscm)

(define (quadmap p)
  (let-values (((x y) (coords p)))
    `(,(+ -0.6 (* -0.1 x) (* 1.1 x x) (* 0.2 x y) (* -0.8 y) (* 0.6 y y))
      ,(+ -0.7 (*  0.7 x) (* 0.7 x x) (* 0.3 x y) (*  0.6 y) (* 0.9 y y)))))

(define (setup)
  (window-title "GLXOESFTTPSV")
  (frame-rate 30)
  (size 512 512)
  (background (hsb 248 1 0.05))
  (color (hsb 248 1 1))
  (origin `(,(/ (width) 2)
            ,(/ (height) 2)))
  (scale (/ (width) 2) (/ (height) 2))
  (set! p '(0 0)))

(define (loop)
  (repeat 100
    (set! p (quadmap p))
    (pixel p)))

(sketch setup loop)

