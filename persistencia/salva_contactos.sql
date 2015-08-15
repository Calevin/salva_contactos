CREATE TABLE contactos (
	rowid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	nombre TEXT,
	apellido TEXT,
	descripcion TEXT
);

CREATE TABLE telefonos (
	numero INTEGER,
	tipo TEXT,
	contacto_rowid INTEGER NOT NULL,
	FOREIGN KEY (contacto_rowid) REFERENCES contactos (rowid) ON DELETE CASCADE
);
