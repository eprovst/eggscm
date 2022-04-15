(module (eggscm window)
        (initialize-window!
         window-title
         window-title!
         width
         height
         size
         size!
         resizable?
         resizable!
         screenshot!
         canvas-flush!
         canvas-fill!
         canvas-pixel
         canvas-pixel-unsafe
         canvas-pixel!
         canvas-pixel-unsafe!)

        (import scheme
          (chicken base)
          (chicken condition)
          (prefix sdl2 "sdl:"))

        (define the-window '())

        (define (canvas)
          (sdl:window-surface the-window))

        (define (initialize-window!)
          ; Initialise SDL
          (sdl:set-main-ready!)
          (sdl:init! '(video))

          ; Register clean up
          (on-exit sdl:quit!)
          (current-exception-handler
            (let ((original-handler (current-exception-handler)))
              (lambda (exception)
                (sdl:quit!)
                (original-handler exception))))

          ; Create a window
          (set! the-window (sdl:create-window! "eggscm"
                                               'undefined 'undefined
                                               600 400))
          (sdl:window-minimum-size-set! the-window '(16 16))
          (sdl:quit-requested?)) ; HACK: wait for full init

        (define (window-title)
          (sdl:window-title the-window))

        (define (window-title! title)
          (sdl:window-title-set! the-window title))

        (define (width)
          (sdl:surface-w (canvas)))

        (define (height)
          (sdl:surface-h (canvas)))

        (define (size)
          (values (width) (height)))

        (define (size! width height)
          (sdl:window-size-set! the-window (list width height)))

        (define (resizable?)
          (sdl:window-resizable? the-window))

        (define (resizable! bool)
          (sdl:window-resizable-set! the-window bool))
        
        (define (screenshot! file)
          (sdl:save-bmp! (canvas) file))

        (define (canvas-flush!)
          (canvas) ; Make sure there is a canvas to flush
          (sdl:update-window-surface! the-window))

        (define (canvas-fill! color)
          (sdl:fill-rect! (canvas) #f color))

        (define (canvas-in-bounds? x y)
          (and (>= x 0) (< x (width))
               (>= y 0) (< y (height))))

        (define (canvas-pixel x y)
          (if (canvas-in-bounds? x y)
            (canvas-pixel-unsafe x y)
            (sdl:make-color 0 0 0 0)))

        (define (canvas-pixel-unsafe x y)
          (sdl:surface-ref (canvas) x y))

        (define (canvas-pixel! x y color)
          (when (canvas-in-bounds? x y)
            (canvas-pixel-unsafe! x y color)))

        (define (canvas-pixel-unsafe! x y color)
          (sdl:surface-set! (canvas) x y color)))
