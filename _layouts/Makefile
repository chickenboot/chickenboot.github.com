LAYOUTS = default.html


all: $(LAYOUTS)


clean:
	rm -f *.html


%.html: haml/%.haml
	bundle exec haml $< $@


.PHONY: all clean
