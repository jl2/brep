;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :brep)

(declaim (inline add-cell
                 create-point create-edge create-face create-body
                 points edges faces cells bodies ptag vertex
                 lower-bound upper-bound)
         (optimize (speed 3)))

(defclass cell ()
  ((ptag :initarg :ptag
         :accessor ptag
         :type fixnum)))

(defclass point (cell)
  ((vertex :initarg :vertex
           :type :vec3)))

(defclass edge (cell)
  ((lower-bound :type point
                :initarg :lower-bound
                :accessor lower-bound)
   (upper-bound :type point
                :initarg :upper-bound
                :accessor upper-bound)))

(defclass face (cell)
  ((edges :initarg :edges
          :accessor edges
          :type (array edge))))

(defclass body (cell)
  ((faces :initarg :faces
          :accessor faces
          :type (array face))))

(defclass brep-container ()
  ((cells :initform (make-array 0
                                :element-type 'cell
                                :adjustable t
                                :fill-pointer 0)
          :type (vector cell)
          :accessor cells)

   (bodies :initform (make-hash-table)
           :accessor bodies
           :type hash-table)
   (faces :initform (make-hash-table)
          :accessor faces
          :type hash-table)
   (edges :initform (make-hash-table)
          :accessor edges
          :type hash-table)
   (points :initform (make-hash-table)
           :accessor points
           :type hash-table)))



(defun add-cell (cells ht cell)
  (declare (type hash-table ht)
           (type (vector cell) cells)
           (type cell cell))
  (let ((ptag (1+ (length cells))))
    (setf (ptag cell)  ptag)
    (vector-push-extend cell cells)
    (setf (gethash ptag ht) cell)
    ptag))

(defun create-point (brep-container vert)
  (declare (type brep-container brep-container)
           (type vec3 vert))
  (with-slots (cells points) brep-container
    (add-cell cells
              points
              (make-instance 'point :vertex vert))))

(defun create-edge (brep-container lower upper)
  (declare (type brep-container brep-container)
           (type fixnum lower upper))
  (with-slots (cells edges) brep-container
    (add-cell cells
              edges
              (make-instance 'edge
                             :lower-bound lower
                             :upper-bound upper))))

(defun list-of-fixnum-p (list)
  "Return t if LIST is non nil and contains only fixnum."
  (and (consp list)
       (every #'integerp list)))

(deftype list-of-ints ()
  `(and list (satisfies list-of-fixnum-p)))

(defun create-face (brep-container &rest edge-ids)
  (declare (type brep-container brep-container)
           (type list-of-ints  edge-ids))
  (with-slots (cells faces) brep-container
    (add-cell cells
              faces
              (make-instance 'edge
                             :edges edge-ids))))

(defun create-body (brep-container &rest face-ids)
  (declare (type brep-container brep-container)
           (type list-of-ints face-ids))
  (with-slots (cells bodies) brep-container
    (add-cell cells
              bodies
              (make-instance 'body
                             :faces face-ids))))
