(import eggscm)

(define points
  (let ((2pi/3 (* 2 pi (/ 3))))
    (vector (pt (cos (- pi/2 2pi/3)) (sin (- pi/2 2pi/3)))
            (pt (cos pi/2) (sin pi/2))
            (pt (cos (+ pi/2 2pi/3)) (sin (+ pi/2 2pi/3))))))

(define v (pt 0 0))

(define (chaos-game-step)
  (let ((pr (vector-ref points (randi 3))))
    (set! v (vec-lerp v pr 0.5))))

(define (setup)
  (window-title! "Sierpińsky triangle")
  (size! 512 512)
  (origin! 'center)
  (background! (gry 0.3))
  (color! (gry 0.9))
  (scale! (/ (width) 2) (/ (height) 2))
  (translate! 0 -50)
  (set! v (pt 0 0))
  (repeat 5 (chaos-game-step)))

(define (loop)
  (repeat 100
    (chaos-game-step)
    (pixel! v))
  (when (> (frame-count) 200)
    (loop! #f)))

(sketch setup loop)
