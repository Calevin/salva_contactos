/*
 * contactos-liststore.vala
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

public class SalvaContactos.ListStoreContactos : Gtk.ListStore {
    public Array<Salva.Entidad> contactos { public get; public set; }
    private ContactoDao contacto_dao;
    public Gtk.TreeSelection seleccionado { public get; public set; }
    public uint id_contacto_seleccionado { public get; public set; }
    public Contacto contacto_seleccionado { public get; public set; }

    enum COLUMNAS {
        ID,
        NOMBRE,
        APELLIDO,
        DESCRIPCION,
        N_COLUMNAS
    }

    public ListStoreContactos () {
        Type[] tipos = { typeof (uint), typeof (string), typeof (string), typeof (string) };
        this.set_column_types ( tipos );

        this.contacto_dao = new ContactoDao ();
        this.contacto_dao.set_db ( new Salva.BaseDeDatos ( Application.db_nombre ) );

        this.cargar_liststore ();
    }

    public void cargar_liststore () {
        Gtk.TreeIter iter;
        this.contactos = this.contacto_dao.get_todos ();
        Contacto contacto;
        for (int i = 0; i < this.contactos.length; i++) {
            contacto = this.contactos.index (i) as Contacto;

            this.append (out iter);
            this.set (iter,
                COLUMNAS.ID, contacto.id,
                COLUMNAS.NOMBRE, contacto.nombre,
                COLUMNAS.APELLIDO, contacto.apellido,
                COLUMNAS.DESCRIPCION, contacto.descripcion);
        }
    }

    public void agregar_contacto ( Contacto contacto ) {
        Gtk.TreeIter iter;
        this.append (out iter);

        this.set (iter,
            COLUMNAS.NOMBRE, contacto.nombre,
            COLUMNAS.APELLIDO, contacto.apellido,
            COLUMNAS.DESCRIPCION, contacto.descripcion);
    }

    public void borrar_contacto_seleccionado ( ) {
        //Borrar de la base
        this.contacto_dao.borrar ( new Contacto.Contacto_id (this.id_contacto_seleccionado) );
        //Borrar del ListStore
        TreeIter iter;
        Value id_row;
        if ( this.get_iter_first(out iter) ) {
            do {
                this.get_value( iter, COLUMNAS.ID, out id_row );

                if ( this.id_contacto_seleccionado == id_row.get_uint () ) {
                    this.remove (iter);
                    break;
                }
            } while ( this.iter_next (ref iter) );
        }
    }

    public void seleccionar_contacto ( Gtk.TreeSelection selection ) {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        uint id;

        if (seleccionado.get_selected (out model, out iter)) {
            model.get (iter, COLUMNAS.ID, out id);
            this.id_contacto_seleccionado = id;
        }
    }
}
