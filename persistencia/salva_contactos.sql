CREATE TABLE contactos (
	nombre TEXT,
	apellido TEXT,
	descripcion TEXT
);

CREATE TABLE telefonos (
	numero INTEGER,
	tipo TEXT,
	contacto_rowid INTEGER NOT NULL,
	FOREIGN KEY (contacto_rowid) REFERENCES contactos (rowid)
);
