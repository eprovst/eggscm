(module (eggscm vectors)
        (origin
         scale
         coords
         point->pixels)

        (import scheme
                (chicken base)
                (eggscm math))

        (define (vect? v)
          (and (= (length v) 2)
               (number? (car v))
               (number? (cadr v))))

        (define (coords v)
          (assert (vect? v))
          (values (car v) (cadr v)))

        (define (map-binary-op op v1 v2)
          (assert (vect? v1))
          (assert (vect? v2))
          (let-values (((x1 y1) (coords v1))
                       ((x2 y2) (coords v2)))
           (list (op x1 x2) (op y1 y2))))

        (define (+. v1 v2)
          (map-binary-op + v1 v2))

        (define the-origin '(0 0))

        (define (origin p)
          (assert (vect? p))
          (set! the-origin p))

        (define the-scale '(1 1))

        (define (scale xs ys)
          (set! the-scale (list xs ys)))

        (define (to-screen-space p)
          (assert (vect? p))
          (+. (map-binary-op * the-scale p)
              the-origin))

        (define (point->pixels p)
          (assert (vect? p))
          (let-values (((x y) (coords (to-screen-space p))))
            (values (f->i x) (f->i y)))))
