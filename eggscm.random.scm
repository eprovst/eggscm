(module (eggscm random)
        (rand-seed!
         rand
         randi
         randn)
         ;noise-seed!
         ;noise-detail!
         ;noise)

        (import scheme
                (chicken base)
                (chicken random)
                (eggscm math))

        ;; Uniform random
        (define (rand-seed! seed)
          (set-pseudo-random-seed! seed))

        (define (rand . args)
          (assert (<= (length args) 2))
          (cond ((null? args)
                 (pseudo-random-real))
                ((= (length args) 1)
                 (let ((s (car args)))
                   (assert (>= s 0))
                   (* s (pseudo-random-real))))
                (else ; (= (length args) 2)
                 (let ((a (car args))
                       (b (cadr args)))
                   (assert (<= a b))
                   (+ a (* (- b a)
                           (pseudo-random-real)))))))

        (define (randi a . other)
          (assert (<= (length other) 1))
          (if (null? other)
              (pseudo-random-integer a)
              (let ((b (car other)))
                (assert (<= a b))
                (+ a (pseudo-random-integer (- b a))))))

        ;; Normal random
        (define (randn)
          (* (sqrt (* -2 (log (pseudo-random-real))))
             (cos (* 2pi (pseudo-random-real))))))

        ;; Perlin noise
        ; TODO...
        ;(define the-noise-seed (randi 2024))

        ;(define (noise-seed! seed)
        ;  (set! the-noise-seed seed))

        ;(define the-noise-lod 4)

        ;(define the-noise-falloff 0.5)

        ;(define (noise-detail! lod . falloff)
        ;  (assert (<= (length falloff) 1))
        ;  (set! the-noise-lod lod)
        ;  (when (not (null? falloff))
        ;    (set! the-noise-falloff (car falloff)))))
