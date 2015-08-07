/*
 * telefonos-liststore.vala
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
using GLib;
using Gtk;
using SalvaContactos;

public class SalvaContactos.ListStoreTelefonos : Gtk.ListStore {
    public Array<Salva.Entidad> telefonos { public get; public set; }
    private TelefonoDao telefono_dao;
    public Gtk.TreeSelection seleccionado { public get; public set; }
    public uint id_contacto_seleccionado { public get; public set; }
    public uint id_telefono_seleccionado { public get; public set; }

    enum COLUMNAS {
        ID,
        NUMERO,
        TIPO,
        N_COLUMNAS
    }

    public ListStoreTelefonos (uint id_contacto_seleccionado) {
        Type[] tipos = { typeof (uint), typeof (uint), typeof (string) };
        this.set_column_types ( tipos );

        this.telefono_dao = new TelefonoDao ();
        this.telefono_dao.set_db ( new Salva.BaseDeDatos ( Application.db_nombre ) );

        this.id_contacto_seleccionado = id_contacto_seleccionado;

        this.cargar_liststore ();
    }

    public void cargar_liststore () {
        Gtk.TreeIter iter;
        string condicion_join = "contacto_rowid=%s".printf ( this.id_contacto_seleccionado.to_string () );
        try {
            this.telefonos = this.telefono_dao.get_todos_segun_condicion ( condicion_join );
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
        Telefono telefono;
        for (int i = 0; i < this.telefonos.length; i++) {
            telefono = this.telefonos.index (i) as Telefono;
            this.append (out iter);
            this.set (iter,
                COLUMNAS.ID, telefono.id,
                COLUMNAS.NUMERO, telefono.numero,
                COLUMNAS.TIPO, telefono.tipo);
        }
    }

    public void recargar_liststore ( ) {
        this.clear ();
        this.cargar_liststore ();
    }

    public void borrar_telefono_seleccionado ( ) {
        try {
        //Borrar de la base
            this.telefono_dao.borrar ( new Telefono.Telefono_id (this.id_telefono_seleccionado) );
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
        //Borrar del ListStore
        TreeIter iter;
        Value id_row;
        if ( this.get_iter_first(out iter) ) {
            do {
                this.get_value( iter, COLUMNAS.ID, out id_row );

                if ( this.id_telefono_seleccionado == id_row.get_uint () ) {
                    this.remove (iter);
                    break;
                }
            } while ( this.iter_next (ref iter) );
        }
        this.id_telefono_seleccionado = 0;
    }

    public void seleccionar_telefono ( Gtk.TreeSelection selection ) {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        uint id;

        if (seleccionado.get_selected (out model, out iter)) {
            model.get (iter, COLUMNAS.ID, out id);
            this.id_telefono_seleccionado = id;
        }
    }
}
