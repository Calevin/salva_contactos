/*
 * contacto-dao.vala
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

public class SalvaContactos.ContactoDao : Salva.EntidadDAO {
    private string[] _propiedades = {"id", "nombre", "apellido", "descripcion"};
    private string _nombre_tabla = "contactos";
    private string _columnas_tabla = "rowid, nombre, apellido, descripcion";
    private Type _tipo_entidad = typeof ( SalvaContactos.Contacto );
    private HashTable<string, string> _relaciones_m2m = new HashTable<string, string> (str_hash, str_equal);

    public ContactoDao ( Salva.IBaseDeDatos db ) {
        base ( db );
    }

    protected override string[] get_propiedades () {
        return this._propiedades;
    }

    protected override string get_nombre_tabla () {
        return this._nombre_tabla;
    }

    protected override string get_columnas_tabla () {
        return this._columnas_tabla;
    }

    protected override Type get_tipo_entidad () {
        return this._tipo_entidad;
    }

    protected override HashTable<string, string>? get_relaciones_m2m () {
        this._relaciones_m2m.insert ( "tags", "contactos_tags" );
        return this._relaciones_m2m;
    }

}
