(module (eggscm color)
        (rgb
         rgba
         hsb
         hsba)

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
          (let* ((h (mod h 360))
                 (s (clamp s 0 1))
                 (b (clamp b 0 1))
                 (k (lambda (n) (mod (+ n (/ h 60)) 6)))
                 (f (lambda (n) (- b (* b s (max 0 (min (k n) (- 4 (k n)) 1)))))))
            (rgba (f 5) (f 3) (f 1) a)))

        (define (hsb h s b)
          (hsba h s b 1)))
