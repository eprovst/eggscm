(import eggscm)

(define cr -0.744)
(define ci 0.148)

(define (julia-iterations x y)
  (do ((i 0 (+ i 1))
       (x x (+ (* x x) (- (* y y)) cr))
       (y y (+ (* 2 x y) ci)))
      ((or (>= i 359)
           (> (+ (* x x) (* y y)) 4)) i)))

(define (setup)
  (window-title! "Julia set")
  (size! 500 300)
  (loop! #f))

(define (draw)
  (time-it ; TODO: it's pretty slow...
    (for i from 0 to (width) do
      (for j from 0 to (height) do
        (let ((x (lmap i 0 (width)  -1.6 1.6))
              (y (lmap j 0 (height) -1.1 1.1)))
          (canvas-pixel-unsafe! i j
            (hsb (radians (julia-iterations x y)) 0.7 1)))))))

(sketch setup draw)
