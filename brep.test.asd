;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :cl-user)
(defpackage :brep.test-asd
  (:use :cl :asdf))
(in-package :brep.test-asd)

(asdf:defsystem #:brep.test
  :description "Test brep"
  :author "Jeremiah LaRocco <jeremiah_larocco@fastmail.com>"
  :license "ISC"
  :version "0.0.1"
  :serial t

  :depends-on ( :brep
                :fiveam)
  
  :components ((:module "t"
                :components
                ((:file "package"))))
  :perform (test-op
            :after (op c)
            (eval
             (read-from-string
              "(every #'fiveam::TEST-PASSED-P
                     (5am:run :brep))"))))
