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
        TAG,
        N_COLUMNAS
    }

    public ListStoreContactos () {
        Type[] tipos = { typeof (uint), typeof (string), typeof (string), typeof (string), typeof (string) };
        this.set_column_types ( tipos );

        this.contacto_dao = new ContactoDao ( Application.get_base_de_datos () );

        this.cargar_liststore ();
    }

    public void cargar_liststore () {
        Gtk.TreeIter iter;
        try {
            this.contactos = this.contacto_dao.get_todos ();
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
        Contacto contacto;
        for (int i = 0; i < this.contactos.length; i++) {
            contacto = this.contactos.index (i) as Contacto;

            this.append (out iter);
            this.set (iter,
                COLUMNAS.ID, contacto.id,
                COLUMNAS.NOMBRE, contacto.nombre,
                COLUMNAS.APELLIDO, contacto.apellido,
                COLUMNAS.DESCRIPCION, contacto.descripcion,
                COLUMNAS.TAG, this.listar_tags ( contacto ) );
        }
    }

    public void recargar_liststore ( ) {
        this.clear ();
        this.cargar_liststore ();
    }

    public void borrar_contacto_seleccionado ( ) {
        try {
        //Borrar de la base
            this.contacto_dao.borrar ( new Contacto.Contacto_id (this.id_contacto_seleccionado) );
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
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
        this.id_contacto_seleccionado = 0;
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

    public string listar_tags ( Contacto contacto) {
        var respuesta = new StringBuilder ();

        TagDao tag_dao = new TagDao ( Application.get_base_de_datos () );
        try {
            Array<Salva.Entidad> tags = this.contacto_dao.
                                                get_entidades_relacionadas ( contacto, tag_dao );

            Tag tag;
            for (int i = 0; i < tags.length; i++) {
                tag = tags.index (i) as Tag;
                respuesta.append ( tag.nombre );

                if ((i + 1) < tags.length) {
                    respuesta.append ( ", ");
                }
            }
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }

        return respuesta.str;
    }
}
