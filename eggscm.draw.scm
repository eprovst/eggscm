(module (eggscm draw)
        (color
         color!
         origin
         origin!
         y-up?
         y-up!
         rotate!
         scale!
         shear-x!
         shear-y!
         translate!
         reset-transform!
         background!
         pixel
         pixel!)

        (import scheme
                (chicken base)
                (eggscm color)
                (eggscm math)
                (eggscm vectors)
                (eggscm window))

        ;; Stroke settings
        (define the-color (rgb 1 1 1))

        (define (color)
          the-color)

        (define (color! color)
          (set! the-color color))

        ;; Coordinate system settings
        (define the-origin (pt 0 0))

        (define (origin)
          (if (equal? the-origin 'center)
              (pt (/ (width) 2) (/ (height) 2))
              the-origin))

        (define (origin! p)
          (assert (or (equal? p 'center)
                      (pt? p)))
          (set! the-origin p))

        (define the-y-up #t)

        (define (y-up?)
          the-y-up)

        (define (y-up! b)
          (assert (boolean? b))
          (when (and (not (equal? the-y-up b))
                     (pt? the-origin))
            (set! the-origin (flip-y the-origin)))
          (set! the-y-up b))

        ;; Transform
        (define the-transform (mat-id))

        (define (translate! xo yo)
          (assert (number? xo))
          (assert (number? yo))
          (set! the-transform
                (mat*mat
                  (mat 1 0 xo
                       0 1 yo
                       0 0  1)
                  the-transform)))

        (define (scale! s . os)
          (assert (<= (length os) 1))
          (if (null? os)
              (scale! s s)
              (let ((xs s)
                    (ys (car os)))
                (assert (number? xs))
                (assert (number? ys))
                (set! the-transform
                      (mat*mat
                        (mat xs  0 0
                              0 ys 0
                              0  0 1)
                        the-transform)))))

        (define (rotate! angle)
          (assert (number? angle))
          (let ((s (sin angle))
                (c (cos angle)))
            (set! the-transform
                  (mat*mat
                    (mat c (- s) 0
                         s     c 0
                         0     0 1)
                    the-transform))))

        (define (shear-x! angle)
          (assert (number? angle))
          (set! the-transform
                (mat*mat
                  (mat 1 (tan angle) 0
                       0           1 0
                       0           0 1)
                  the-transform)))

        (define (shear-y! angle)
          (assert (number? angle))
          (set! the-transform
                (mat*mat
                  (mat           1 0 0
                       (tan angle) 1 0
                                 0 0 1)
                  the-transform)))

        (define (reset-transform!)
          (set! the-transform (mat-id)))

        ;; Coordinate transform
        (define (flip-y p)
          (assert (pt? p))
          (vec (vec-idx p 0)
               (- (height) (vec-idx p 1))
               (vec-idx p 2)))

        (define (to-screen-space p)
          (assert (pt? p))
          (let* ((Tp  (mat*vec the-transform p))
                 (sTp (pt-add-x-y Tp (origin))))
            (if (y-up?) (flip-y sTp) sTp)))

        (define (point->pixel p)
          (let-values (((x y) (crds (to-screen-space p))))
            (values (integer x) (integer y))))

        ;; Drawing functions
        (define (background! color)
          (canvas-fill! color))

        (define (pixel p)
          (let-values (((x y) (point->pixel p)))
            (canvas-pixel x y)))

        (define (pixel! p)
          (let-values (((x y) (point->pixel p)))
            (canvas-pixel! x y the-color))))
