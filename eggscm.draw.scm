(module (eggscm draw)
        (background!
         pixel
         pixel!
         color
         color!
         push-style!
         pop-style!
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
         push-transform!
         pop-transform!
         push!
         pop!)

        (import scheme
                (chicken base)
                (eggscm color)
                (eggscm math)
                (eggscm vectors)
                (eggscm window))

        ;; Drawing functions
        (define (background! color)
          (canvas-fill! color))

        (define (pixel p)
          (let-values (((x y) (point->pixel p)))
            (canvas-pixel x y)))

        (define (pixel! p)
          (let-values (((x y) (point->pixel p)))
            (canvas-pixel! x y (color))))

        ;; Style settings
        (define the-style
         (vector (rgb 1 1 1)))

        (define (color)
          (vector-ref the-style 0))

        (define (color! color)
          (vector-set! the-style 0 color))

        ;; Style stack
        (define the-style-stack '())

        (define (push-style!)
          (set! the-style-stack
                (cons the-style
                      the-style-stack)))

        (define (pop-style!)
          (when (not (null? the-style-stack))
            (set! the-style
              (car the-style-stack))
            (set! the-style-stack
              (cdr the-style-stack))))

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
                  (mat 1 (- (tan angle)) 0
                       0               1 0
                       0               0 1)
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

        ;; Transform stack
        (define the-transform-stack '())

        (define (push-transform!)
          (set! the-transform-stack
                (cons the-transform
                      the-transform-stack)))

        (define (pop-transform!)
          (when (not (null? the-transform-stack))
            (set! the-transform
              (car the-transform-stack))
            (set! the-transform-stack
              (cdr the-transform-stack))))

        ;; Control both transform and style stacks
        (define (push!)
          (push-style!)
          (push-transform!))

        (define (pop!)
          (pop-style!)
          (pop-transform!))

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
            (values (integer x) (integer y)))))
