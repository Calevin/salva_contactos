/*
 * telefonos-box.vala
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
using Salva;
using SalvaContactos;

public class SalvaContactos.TelefonosBox {
    public Gtk.Box box_numeros { public get; public set; }
    private Gtk.ListBox listbox_numeros { public get; public set; }
    private ContactoDao contacto_dao;
    private TelefonoDao telefono_dao;
    public bool hay_numeros_cargados { public get; private set; default = false; }

    public TelefonosBox () {
        this.box_numeros = new Gtk.Box ( Gtk.Orientation.VERTICAL, 0 );
        this.box_numeros.add ( new Gtk.Label ( "Numeros" ) );
        this.box_numeros.add ( new Gtk.Separator ( Gtk.Orientation.HORIZONTAL ));

        this.crear_listbox_numeros ();
        //DAOs
        contacto_dao = new ContactoDao ();
        telefono_dao = new TelefonoDao ();
        BaseDeDatos db = new BaseDeDatos ( Application.db_nombre );
        contacto_dao.set_db ( db );
        telefono_dao.set_db ( db );
    }

    public void crear_listbox_numeros () {
        this.listbox_numeros = new Gtk.ListBox ();
        this.listbox_numeros.set_activate_on_single_click( true );
        this.listbox_numeros.set_selection_mode( Gtk.SelectionMode.SINGLE );
        this.listbox_numeros.set_placeholder( new Gtk.Label( null ) );
        this.box_numeros.add ( this.listbox_numeros );
    }

    public void limpiar_listbox_numeros () {
        if ( this.hay_numeros_cargados ) {
            this.box_numeros.remove ( this.listbox_numeros );
            this.listbox_numeros = null;
            this.hay_numeros_cargados = false;
        }
    }

    private void agregar_numero_listbox_numeros ( Array<Salva.Entidad> telefonos ) {
        string label_numero = "";
        Telefono row_telefono;
        for (int i = 0; i < telefonos.length; i++) {
            row_telefono = telefonos.index (i) as Telefono;
            label_numero = "Numero: %s (%s)".printf ( row_telefono.numero.to_string () , row_telefono.tipo );
            this.listbox_numeros.add (new Gtk.Label( label_numero ) );
            this.hay_numeros_cargados = true;
        }
    }

    public void cargar_numeros ( uint contacto_id) {
        this.limpiar_listbox_numeros ();

        this.crear_listbox_numeros ();
        Array<Salva.Entidad> telefonos = contacto_dao.get_entidades_relacionadas (
                new Contacto.Contacto_id ( contacto_id ),
                telefono_dao );

        if ( telefonos.length > 0 ) {
            this.agregar_numero_listbox_numeros ( telefonos );
        }

        this.listbox_numeros.show_all ();
    }
}
