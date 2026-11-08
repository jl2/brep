;; Copyright (c) 2026 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

(in-package :brep)

(defun tessellate (brep-container &rest cells)
  (declare (ignorable brep-container cells))
  )

(defclass brep-window (mingl:3d-window)
  (
   (click-start :initform nil)

   (vao :initform 0)
   (program :initform nil)

   (buffers)
   (vertices)
   (indices)
   (brep-container)
   (cells :initform nil)
   ;;  (joystick :initform 0 :initarg :joystick)
   ))

(defun display (brep-container &rest cells)
  (mingl:add-shader-search-directory (asdf:system-relative-pathname :brep "shaders/"))
  (let ((window (make-instance 'brep-window
                               :brep-container brep-container
                               :cells cells
                               :use-main-thread t
                               :wait-for-exit nil)))
    (mingl:display window)))





(defmethod initialize ((gl-window brep-window))
  (with-slots (vao buffers vertices indices program) gl-window
    (setf vao (gl:gen-vertex-array))
    (gl:bind-vertex-array vao)

    (setf buffers (gl:gen-buffers 2))
    (gl:bind-buffer :array-buffer (car buffers))

    (let* ((width 10)
           (height 10)
           (depth 10)
           (max-corner (vec3 100 100 100))
           (min-corner (vec3 -100 -100 -100))
           (step (v/ (v- max-corner
                         min-corner)
                     (vec3 (if (= width 1)
                               1
                               (1- width))
                           (if (= height 1)
                               1
                               (1- height))
                           (if (= depth 1)
                               1
                               (1- depth)))))
           (data (loop
                   :for i :below width
                   :collecting
                   (loop
                     :for j :below height
                     :collecting
                     (loop
                       :for k :below depth
                       :for pt = (v+
                                  min-corner
                                  (v* (vec3 i j k) step))
                       :collecting pt
                       :collecting (let* ((r (random 1.0))
                                          (g (+ 0.5 (random 0.5)))
                                          (b (random 1.0))
                                          (alpha 0.5))
                                     (vec4 r g b alpha)))))))
      (setf vertices (mingl:to-gl-array :float
                                  (* 7 width height depth)
                                  data))
      (gl:buffer-data :array-buffer :static-draw vertices)
      (gl:bind-buffer :element-array-buffer (cadr buffers))

      (setf indices (mingl:to-gl-array :unsigned-int
                                       (* width height depth)
                                       (loop :for i :below (* width height depth) :collecting i)))
      (gl:buffer-data :element-array-buffer :static-draw indices))

    (setf program (mingl:make-shader-program "brep.geom" "brep.frag" "brep.vert"))
    (mingl:build-shader-program program)
    (mingl:use-shader-program program)


    (with-slots (mingl::program) program
      (let ((pos-location (gl:get-attrib-location mingl::program "in_position"))
            (pos-color (gl:get-attrib-location mingl::program "in_color")))
        (when (>= pos-location 0)
          (gl:enable-vertex-attrib-array pos-location)
          (gl:vertex-attrib-pointer pos-location
                                    3
                                    :float
                                    nil
                                    (* 7 4)
                                    0))
        (when (>= pos-color 0 )
          (gl:enable-vertex-attrib-array pos-color)
          (gl:vertex-attrib-pointer pos-color
                                    4
                                    :float
                                    nil
                                    (* 5 4)
                                    #.(* 3 4))))))
  (call-next-method))

(defmethod render ((window brep-window))
  (call-next-method)
  (with-slots (vao buffers program primitive-type depth width height) window
    (mingl:use-shader-program program)

    (gl:bind-buffer :array-buffer (car buffers))
    (gl:bind-buffer :element-array-buffer (cadr buffers))
    (gl:draw-elements primitive-type
                      (gl:make-null-gl-array :unsigned-int)
                      :count (* depth width height))))

(defmethod cleanup ((window brep-window))
  (when (slot-boundp window 'vertices)
    (with-slots (vao buffers vertices indices) window
      (gl:bind-vertex-array vao)

      (gl:delete-buffers buffers)
      (gl:bind-buffer :array-buffer 0)
      (gl:bind-buffer :element-array-buffer 0)
      (gl:free-gl-array vertices)
      (gl:free-gl-array indices)
      (gl:bind-vertex-array 0)
      (gl:delete-vertex-arrays (list vao))))

  (call-next-method))
