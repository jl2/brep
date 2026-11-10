;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :cl-user)
(defpackage :brep.test
  (:use :cl
        :fiveam
        :alexandria
        :brep
        :3d-vectors
        :3d-matrices))

(in-package :brep.test)

(def-suite :brep)
(in-suite :brep)

(test basic-face
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

    (with-slots
          (brep::faces brep::points brep::edges brep::cells) bc


      (is (= 9 (length brep::cells)))

      (is (= 1 (hash-table-count brep::faces)))
      (is (= 4 (hash-table-count brep::edges)))
      (is (= 4 (hash-table-count brep::points)))

      (is (= 4 (length (brep::edges (brep:get-cell bc the-face)))))

      (is (equal (list edge0 edge1 edge2 edge3)
                 (brep::edges (brep:get-cell bc the-face))))

      (is (= 2 (brep:dimension (get-cell bc the-face))))
      (is (= 1 (brep:dimension (get-cell bc edge3))))
      (is (= 0 (brep:dimension (get-cell bc pt2))))

      )))


