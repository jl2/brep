;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :brep)

(declaim (inline add-cell
                 create-point create-edge create-face create-body
                 points faces cells bodies ptag vertex
                 get-cell
                 )
         (optimize (speed 3) (safety 0) (debug 0))
         (optimize (sb-c::insert-array-bounds-checks 0)))

(defclass display-properties ()
  ((hidden :initform nil
            :type (or nil t)
           :initarg :hidden)
   (color :initform (vec4 1 1 1 1)
          :type vec4
          :initarg :color)))

(defclass cell ()
  ((ptag :initarg :ptag
         :accessor ptag
         :type fixnum)
   (display-properties :initarg :display-properties
                       :accessor display-properties
                       :type display-properties)
   (properties :initarg properties
               :accessor properties
               :type list)))


(defclass point (cell)
  ((vertex :initarg :vertex
           :type vec3)))


(defclass edge (cell)
  ((points :initarg :points
           :accessor points
           :type (simple-array fixnum))
   ;; (lower-bound :type fixnum
   ;;              :initarg :lower-bound
   ;;              :accessor lower-bound)
   ;; (upper-bound :type fixnum
   ;;              :initarg :upper-bound
   ;;              :accessor upper-bound)
   ))

(defclass face (cell)
  ((edges :initarg :edges
          :accessor edges
          :type (simple-array fixnum))))

(defclass body (cell)
  ((faces :initarg :faces
          :accessor faces
          :type (array fixnum))))

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
           :type hash-table)
   (adjacencies :initform (make-hash-table)
                :accessor adjacencies
                :type hash-table)))

(defclass assembly ()
  ((instances :initform (make-array 0
                                    :element-type 'instance
                                    :adjustable t
                                    :fill-pointer 0)
               :initarg :instances
               :type (vector instance))))

(defclass instance ()
  ((entity :initarg :entity
           :type (or assembly brep-container))))

(define-condition invalid-ptag-error (error)
  ((ptag :initarg :ptag
         :reader ptag
         :documentation "The ptag that was not found.")
   (ptag-count :initarg :ptag-count
               :reader :ptag-count
               :documentation "The number of ptags.")))

(defun get-cell (brep-container ptag)
  (with-slots (cells) brep-container
    (declare (type (vector cell) cells))
    (when (or (>= ptag (length cells))
              (< ptag 0))
      (error 'invalid-ptag-error
             :ptag ptag
             :ptag-count (length cells)))
    (aref cells ptag)))

(defgeneric evaluate (brep-container cell &rest position)
  (:documentation "Return a point on cell at a certain position.
The number of &rest arguments depends on the cell type."))


(defgeneric dimension (cell)
  (:documentation "Return the dimension of the cell."))

(defmethod dimension ((cell point))
  0)
(defmethod dimension ((cell edge))
  1)
(defmethod dimension ((cell face))
  2)
(defmethod dimension ((cell body))
  3)

(defun add-cell (cells ht cell)
  (declare (type hash-table ht)
           (type (vector cell) cells)
           (type cell cell))
  (let ((ptag (length cells)))
    (declare (type fixnum ptag))
    (setf (ptag cell)  ptag)
    (vector-push-extend cell cells)
    (setf (gethash ptag ht) cell)
    ptag))

(defun create-point (brep-container vert)
  "Create a new point.  Return the ptag."
  (declare (type brep-container brep-container)
           (type vec3 vert))
  (with-slots (cells points) brep-container
    (add-cell cells
              points
              (make-instance 'point :vertex vert))))

(defun create-edge (brep-container lower upper)
  "Create a new edge between two point IDs. Return the ptag."
  (declare (type brep-container brep-container)
           (type fixnum lower upper))
  (with-slots (cells edges adjacencies) brep-container
    (let ((new-ptag (add-cell cells
                              edges
                              (make-instance 'edge :points (make-array 2
                                                                       :element-type 'fixnum
                                                                       :initial-contents `(,lower ,upper))))))
      (push lower (gethash new-ptag adjacencies))
      (push upper (gethash new-ptag adjacencies))
      (push new-ptag (gethash lower adjacencies))
      (push new-ptag (gethash upper adjacencies))
      new-ptag)))

(defun list-of-fixnum-p (list)
  "Return t if LIST is non nil and contains only fixnum."
  (and (consp list)
       (every #'integerp list)))

(deftype list-of-ints ()
  `(and list (satisfies list-of-fixnum-p)))

(defun create-face (brep-container &rest edge-ids)
  "Create a new face from a list of edge IDs. Return the ptag."
  (declare (type brep-container brep-container)
           (type list-of-ints edge-ids))
  (with-slots (cells faces adjacencies) brep-container
    (let ((new-ptag (add-cell cells
                              faces
                              (make-instance 'face
                                             :edges (make-array (length edge-ids)
                                                                :element-type 'fixnum
                                                                :initial-contents edge-ids)))))
      (loop
        :for id :in edge-ids
        :do
           (push new-ptag (gethash id adjacencies))
           (push id (gethash new-ptag adjacencies)))
      new-ptag)))

(defun create-body (brep-container &rest face-ids)
  (declare (type brep-container brep-container)
           (type list-of-ints face-ids))
  (with-slots (cells  adjacencies bodies) brep-container
    (let ((new-ptag (add-cell cells
                              bodies
                              (make-instance 'body
                                             :faces (make-array (length face-ids)
                                                                :element-type 'fixnum
                                                                :initial-contents face-ids)))))
      (loop
        :for id :in face-ids
        :do
           (push new-ptag(gethash id adjacencies))
           (push id (gethash new-ptag adjacencies)))
      new-ptag)))

(defmethod evaluate (brep-container (cell point) &rest args)
  (declare (ignorable args))
  (slot-value cell 'vertex))


(defmethod evaluate (brep-container (cell edge) &rest args)
  (with-slots (points) cell
    (declare (type (vector fixnum) points))
    (let* ((t-val (car args))
           (lower-bound (aref points 0))
           (upper-bound (aref points 1))
           (min-point (evaluate brep-container
                                (get-cell brep-container lower-bound)))
           (max-point (evaluate brep-container
                                (get-cell brep-container upper-bound))))
      (v+ min-point
          (v* t-val (v- max-point min-point))))))

(defmethod evaluate (brep-container (cell face) &rest args)
  (let ((u-val (car args))
        (v-val (cadr args)))
    (vec3 u-val v-val 0.0)))

(defmethod evaluate (brep-container (cell fixnum) &rest args)
  (apply #'evaluate
         brep-container
         (get-cell brep-container cell)
         args))
