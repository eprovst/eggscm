(module eggscm *
        (import
         scheme
         (chicken module)

         (eggscm color)
         (eggscm draw)
         (eggscm io)
         (eggscm iteration)
         (eggscm math)
         (eggscm random)
         (eggscm vectors)
         (eggscm sketch)
         (eggscm time)
         (eggscm window))

        (reexport
         (eggscm color)
         (eggscm draw)
         (eggscm io)
         (eggscm iteration)
         (eggscm math)
         (eggscm random)
         (eggscm vectors)
         (eggscm sketch)
         (eggscm time)
         (eggscm window)))
