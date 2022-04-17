(module (eggscm color)
        (rgb
         rgba
         hsb
         hsba
         gry
         grya
         color-lerp)

        (import scheme
          (eggscm math)
          (prefix sdl2 "sdl:"))

        (define (rgba r g b a)
          (sdl:make-color
           (integer (* 255 (clamp r 0 1)))
           (integer (* 255 (clamp g 0 1)))
           (integer (* 255 (clamp b 0 1)))
           (integer (* 255 (clamp a 0 1)))))

        (define (rgb r g b)
          (rgba r g b 1))

        (define (hsba h s b a)
          (let* ((h (mod h 2pi))
                 (s (clamp s 0 1))
                 (b (clamp b 0 1))
                 (k (lambda (n) (mod (+ n (/ h pi/3)) 6)))
                 (f (lambda (n k) (- b (* b s (clamp (min k (- 4 k)) 0 1))))))
            (rgba (f 5 (k 5)) (f 3 (k 3)) (f 1 (k 1)) a)))

        (define (hsb h s b)
          (hsba h s b 1))

        (define (grya g a)
          (rgba g g g a))

        (define (gry g)
          (grya g 1))

        (define (color-lerp c1 c2 t)
          (sdl:color-lerp c1 c2 t)))
