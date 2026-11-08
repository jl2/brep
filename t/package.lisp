;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :cl-user)
(defpackage :brep.test
  (:use :cl
        :fiveam
        :alexandria
        :brep))

(in-package :brep.test)

(def-suite :brep)
(in-suite :brep)

(test points
  (is-true t))
