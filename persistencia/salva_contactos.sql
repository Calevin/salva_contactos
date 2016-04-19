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

CREATE TABLE tags (
	rowid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	nombre TEXT,
	descripcion TEXT
);

CREATE TABLE contactos_tags (
	rowid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	contacto_rowid INTEGER NOT NULL,
	tag_rowid INTEGER NOT NULL,
	FOREIGN KEY (contacto_rowid) REFERENCES contactos (rowid),
	FOREIGN KEY (tag_rowid) REFERENCES tags (rowid)
);
