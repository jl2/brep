;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(defpackage :brep

  (:nicknames)

  (:use #:cl
        #:alexandria
        #:3d-vectors
        #:3d-matrices)

  (:export

   #:main

   ;; Basic entity types
   #:cell
   #:point
   #:edge
   #:face
   #:body
   #:dimension
   #:evaluate

   ;; A collection of related BREP
   #:brep-container
   #:add-cell
   #:create-point
   #:create-edge
   #:create-face
   #:create-body


   ;; Display
   #:brep-window
   #:display
   #:tessellate
   ))
