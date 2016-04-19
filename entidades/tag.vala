/*
 * contacto.vala
 * Copyright (C) 2015 Sebastian Barreto <sebastian.e.barreto@gmail.com>
 *
 * salva_contactos is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * salva_contactos is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using Salva;

public class SalvaContactos.Tag : Salva.Entidad {
    public string nombre { public get; public set; }
    public string descripcion { public get; public set; }

    public Tag ( uint id, string nombre, string descripcion ) {
        base ( id );
        this._nombre = nombre;
        this._descripcion = descripcion;
    }

    public Tag.Tag_sin_id ( string nombre, string descripcion ) {
        base.Entidad_sin_id ( );
        this._nombre = nombre;
        this._descripcion = descripcion;
    }

    public Tag.Tag_id ( uint id ) {
        base ( id );
    }
}
