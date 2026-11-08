;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(asdf:defsystem #:brep
  :description ""
  :author "Jeremiah LaRocco <jeremiah_larocco@fastmail.com>"
  :license  "ISC"
  :version "0.0.1"
  :serial t

  :depends-on (#:alexandria
               #:gtools
               #:3d-vectors
               #:3d-matrices
               #:functional-json
               #:mingl
               #:gtools
               )

  :components ((:file "package")
               (:file "main")
               (:file "brep")
               (:file "visualization"))

  :in-order-to ((test-op (test-op
                          brep.test))))
