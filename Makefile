# Build brep

brep: *.lisp *.asd Makefile
	buildapp --output brep \
             --load ~/quicklisp/setup.lisp \
             --eval '(ql:quickload :brep)' \
             --entry 'brep:main'

test: t/*.lisp *.lisp *.asd Makefile
	sbcl --eval "(ql:quickload :brep.test)" \
		 --eval "(setf 5am::*on-error* :debug)" \
		 --eval "(5am:run-all-tests :summary :suite)" \
		 --eval "(quit)"

clean:
	rm -Rf *.fasl

.PHONY: clean test
