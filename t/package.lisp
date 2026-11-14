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

      (is (equalp (make-array 4 :element-type 'fixnum
                               :initial-contents (list edge0 edge1 edge2 edge3))
                 (brep::edges (brep:get-cell bc the-face))))

      (is (= 2 (brep:dimension (get-cell bc the-face))))
      (is (= 1 (brep:dimension (get-cell bc edge3))))
      (is (= 0 (brep:dimension (get-cell bc pt2))))

      )))


(test point-evaluate
  (let* ((bc (make-instance 'brep:brep-container))
         (pt0 (brep:create-point bc (vec3 0 0 0)))
         (pt1 (brep:create-point bc (vec3 1 0 0)))
         (pt2 (brep:create-point bc (vec3 0 1 0)))
         (pt3 (brep:create-point bc (vec3 1 1 0))))
    (is (v= (Vec3 0 0 0) (brep:evaluate bc pt0)))
    (is (v= (Vec3 1 0 0) (brep:evaluate bc pt1)))
    (is (v= (Vec3 0 1 0) (brep:evaluate bc pt2)))
    (is (v= (Vec3 1 1 0) (brep:evaluate bc pt3)))))

(test edge-evaluate
  (let* ((bc (make-instance 'brep:brep-container))
         (pt0 (brep:create-point bc (vec3 0 0 0)))
         (pt1 (brep:create-point bc (vec3 1 0 0)))
         (edge0 (brep:create-edge bc pt0 pt1)))
    (is (v= (Vec3 0 0 0) (brep:evaluate bc pt0)))
    (is (v= (Vec3 1 0 0) (brep:evaluate bc pt1)))
    (is (v= (Vec3 0.5 0 0) (brep:evaluate bc edge0 0.5)))
    (is (v= (Vec3 1 0 0) (brep:evaluate bc edge0 1)))))

(test face-evaluate
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
    (is (v= (Vec3 0.5 0.5 0) (brep:evaluate bc the-face 0.5 0.5)))
    (is (v= (Vec3 1.0 0.5 0) (brep:evaluate bc the-face 1.0 0.5)))
    ))
