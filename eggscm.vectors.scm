(module (eggscm vectors) *

        (import scheme
                (chicken base)
                (chicken condition))

        ;; Points and vectors as homogeneous 3-vectors
        (define (pt x y)
          (vec x y 1))

        (define (pt? p)
          (and (vec? p)
               (not (zero? (vec-idx p 2)))))

        (define (vt x y)
          (vec x y 0))

        (define (vt? v)
          (and (vec? v)
               (zero? (vec-idx v 2))))

        (define (vt-or-pt? v)
          (or (vt? v) (pt? v)))

        (define (crds v)
          (assert (vec? v))
          (let ((s (vec-idx v 2)))
            (if (zero? s)
              ; Pure vector
              (values (vec-idx v 0)
                      (vec-idx v 1))
              ; Point
              (values (/ (vec-idx v 0) s)
                      (/ (vec-idx v 1) s)))))

        (define (pt-add-x-y p1 p2)
          (assert (pt? p1))
          (assert (pt? p2))
          (let-values (((x1 y1) (crds p1))
                       ((x2 y2) (crds p2)))
            (pt (+ x1 x2) (+ y1 y2))))

        ;; Underlying 3-vectors and 3-matrix operations
        (define (vec x y o)
          (assert (number? x))
          (assert (number? y))
          (assert (number? o))
          (vector x y o))

        (define (vec? v)
          (and (vector? v)
               (= (vector-length v) 3)
               (number? (vector-ref v 0))
               (number? (vector-ref v 1))
               (number? (vector-ref v 2))))

        (define (vec-idx v i)
          (assert (vec? v))
          (vector-ref v i))

        (define (scl+vec s v)
          (assert (number? s))
          (assert (vec? v))
          (vec (+ s (vec-idx v 0))
               (+ s (vec-idx v 1))
               (+ s (vec-idx v 2))))

        (define (vec-scl v s)
          (assert (number? s))
          (assert (vec? v))
          (vec (- (vec-idx v 0) s)
               (- (vec-idx v 1) s)
               (- (vec-idx v 2) s)))

        (define (scl*vec s v)
          (assert (number? s))
          (assert (vec? v))
          (vec (* s (vec-idx v 0))
               (* s (vec-idx v 1))
               (* s (vec-idx v 2))))

        (define (vec+vec v1 v2)
          (assert (vec? v1))
          (assert (vec? v2))
          (vec (+ (vec-idx v1 0) (vec-idx v2 0))
               (+ (vec-idx v1 1) (vec-idx v2 1))
               (+ (vec-idx v1 2) (vec-idx v2 2))))

        (define (vec-vec v1 v2)
          (assert (vec? v1))
          (assert (vec? v2))
          (vec (- (vec-idx v1 0) (vec-idx v2 0))
               (- (vec-idx v1 1) (vec-idx v2 1))
               (- (vec-idx v1 2) (vec-idx v2 2))))

        (define (vec*vec v1 v2)
          (assert (vec? v1))
          (assert (vec? v2))
          (+ (* (vec-idx v1 0) (vec-idx v2 0))
             (* (vec-idx v1 1) (vec-idx v2 1))
             (* (vec-idx v1 2) (vec-idx v2 2))))

        (define (vec-lerp v1 v2 t)
          (assert (vec? v1))
          (assert (vec? v2))
          (assert (number? t))
          (vec+vec v1 (scl*vec t (vec-vec v2 v1))))

        (define (norm v)
          (assert (vec? v))
          (sqrt (vec*vec v v)))

        (define (dist v1 v2)
          (assert (vec? v1))
          (assert (vec? v2))
          (norm (vec-vec v2 v1)))

        (define (mat m00 m01 m02
                     m10 m11 m12
                     m20 m21 m22)
          (vector (vec m00 m01 m02)
                  (vec m10 m11 m12)
                  (vec m20 m21 m22)))

        (define (mat-id)
          (mat 1 0 0
               0 1 0
               0 0 1))

        (define (mat? m)
          (and (vector? m)
               (= (vector-length m) 3)
               (vec? (vector-ref m 0))
               (vec? (vector-ref m 1))
               (vec? (vector-ref m 2))))

        (define (mat-idx m i j)
          (assert (mat? m))
          (vec-idx (vector-ref m i) j))

        (define (mat-row m i)
          (assert (mat? m))
          (vector-ref m i))

        (define (mat-col m j)
          (assert (mat? m))
          (vec (mat-idx m 0 j)
               (mat-idx m 1 j)
               (mat-idx m 2 j)))

        (define (scl+mat s m)
          (assert (number? s))
          (assert (mat? m))
          (vector (scl+vec s (mat-row m 0))
                  (scl+vec s (mat-row m 1))
                  (scl+vec s (mat-row m 2))))

        (define (mat-scl m s)
          (assert (number? s))
          (assert (mat? m))
          (vector (vec-scl (mat-row m 0) s)
                  (vec-scl (mat-row m 1) s)
                  (vec-scl (mat-row m 2) s)))

        (define (scl*mat s m)
          (assert (number? s))
          (assert (mat? m))
          (vector (scl*vec s (mat-row m 0))
                  (scl*vec s (mat-row m 1))
                  (scl*vec s (mat-row m 2))))

        (define (mat*vec m v)
          (assert (mat? m))
          (assert (vec? v))
          (vec (vec*vec (mat-row m 0) v)
               (vec*vec (mat-row m 1) v)
               (vec*vec (mat-row m 2) v)))

        (define (vec*mat v m)
          (assert (vec? v))
          (assert (mat? m))
          (vec (vec*vec v (mat-col m 0))
               (vec*vec v (mat-col m 1))
               (vec*vec v (mat-col m 2))))

        (define (mat+mat m1 m2)
          (assert (mat? m1))
          (assert (mat? m2))
          (vector (vec+vec (mat-row m1 0) (mat-row m2 0))
                  (vec+vec (mat-row m1 1) (mat-row m2 1))
                  (vec+vec (mat-row m1 2) (mat-row m2 2))))

        (define (mat-mat m1 m2)
          (assert (mat? m1))
          (assert (mat? m2))
          (vector (vec-vec (mat-row m1 0) (mat-row m2 0))
                  (vec-vec (mat-row m1 1) (mat-row m2 1))
                  (vec-vec (mat-row m1 2) (mat-row m2 2))))

        (define (mat*mat m1 m2)
          (assert (mat? m1))
          (assert (mat? m2))
          (vector (vec*mat (mat-row m1 0) m2)
                  (vec*mat (mat-row m1 1) m2)
                  (vec*mat (mat-row m1 2) m2)))

        ;; Simplify matrix/vector operations
        (define (add a b)
          (cond ((and (number? a) (number? b)) (+ a b))
                ((and (number? a) (vec? b)) (scl+vec a b))
                ((and (vec? a) (number? b)) (scl+vec b a))
                ((and (vec? a) (vec? b)) (vec+vec a b))
                ((and (number? a) (mat? b)) (scl+mat a b))
                ((and (mat? a) (number? b)) (scl+mat b a))
                ((and (mat? a) (mat? b)) (mat+mat a b))
                (else (abort "no available addition routine for a and b."))))

        (define (mul a b)
          (cond ((and (number? a) (number? b)) (* a b))
                ((and (number? a) (vec? b)) (scl*vec a b))
                ((and (vec? a) (number? b)) (scl*vec b a))
                ((and (vec? a) (vec? b)) (vec*vec a b))
                ((and (number? a) (mat? b)) (scl*mat a b))
                ((and (mat? a) (number? b)) (scl*mat b a))
                ((and (mat? a) (vec? b)) (mat*vec a b))
                ((and (vec? a) (mat? b)) (vec*mat a b))
                ((and (mat? a) (mat? b)) (mat*mat a b))
                (else (abort "no available multiplication routine for a and b."))))

        (define dot mul)

        (define (neg a)
          (mul -1 a))

        (define (sub a b)
          (cond ((and (number? a) (number? b)) (- a b))
                ((and (vec? a) (number? b)) (vec-scl a b))
                ((and (vec? a) (vec? b)) (vec-vec a b))
                ((and (mat? a) (number? b)) (mat-scl a b))
                ((and (mat? a) (mat? b)) (mat-mat a b))
                (else (add a (neg b))))))
