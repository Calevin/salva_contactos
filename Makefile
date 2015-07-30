all:
	make source

SOURCE_FILES_MAIN=./interfaz/salva-contactos-main.vala ./interfaz/salva-contactos-application.vala ./interfaz/contactos-liststore.vala ./interfaz/contactos-agregar-dialog.vala
SOURCE_FILES_ENTITIES=./entidades/contacto.vala ./entidades/telefono.vala
SOURCE_FILES_DAOS=./persistencia/contacto-dao.vala ./persistencia/telefono-dao.vala
SOURCE_FILES=$(SOURCE_FILES_MAIN) $(SOURCE_FILES_ENTITIES) $(SOURCE_FILES_DAOS)
PACKAGES=--pkg sqlite3 --pkg gtk+-3.0 --pkg salva

source:
	rm -f ./salva_contactos
	valac $(SOURCE_FILES) $(PACKAGES) -o salva_contactos

run:
	./salva_contactos
