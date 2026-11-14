;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :brep)

(defun main (args)
  (let* ((bc (make-instance 'brep:brep-container))

         (pt0 (brep:create-point bc (vec3 0 0 0)))
         (pt1 (brep:create-point bc (vec3 1 0 0)))
         (pt2 (brep:create-point bc (vec3 0 1 0)))
         (pt3 (brep:create-point bc (vec3 1 1 0)))

         (edge0 (brep:create-edge bc pt0 pt1))
         (edge1 (brep:create-edge bc pt1 pt3))
         (edge2 (brep:create-edge bc pt3 pt2))
         (edge3 (brep:create-edge bc pt2 pt0))

         (the-face (brep:create-face bc edge0 edge1 edge2 edge3)))
    (display bc the-face))
  0)
