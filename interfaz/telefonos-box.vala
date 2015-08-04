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
    private Gtk.Button numeros_button_agregar;
    private Gtk.Button numeros_button_editar;
    private Gtk.Button numeros_button_borrar;
    public Gtk.Box box_numeros { public get; public set; }
    private Gtk.ListBox listbox_numeros { public get; public set; }
    private ContactoDao contacto_dao;
    private TelefonoDao telefono_dao;
    public bool hay_numeros_cargados { public get; private set; default = false; }
    private uint id_contacto_seleccionado;
    TelefonoAgregarDialog guardar_dialog;

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

        Gtk.Box secondary_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);

        numeros_button_agregar = new Gtk.Button.from_icon_name ("list-add", Gtk.IconSize.SMALL_TOOLBAR);
        numeros_button_agregar.clicked.connect ( this.crear_dialog_agregar_telefono );
        numeros_button_agregar.set_sensitive ( false );
        secondary_box.pack_start ( numeros_button_agregar );
        numeros_button_editar = new Gtk.Button.with_label  ("Editar");
        secondary_box.pack_start ( numeros_button_editar );
        numeros_button_editar.set_sensitive ( false );
        numeros_button_borrar = new Gtk.Button.from_icon_name ("list-remove", Gtk.IconSize.SMALL_TOOLBAR);
        secondary_box.pack_start ( numeros_button_borrar );
        numeros_button_borrar.set_sensitive ( false );

        this.box_numeros.pack_end ( secondary_box ,false );
    }

    public void crear_listbox_numeros () {
        this.listbox_numeros = new Gtk.ListBox ();
        this.listbox_numeros.set_activate_on_single_click( true );
        this.listbox_numeros.set_selection_mode( Gtk.SelectionMode.SINGLE );
        this.listbox_numeros.set_placeholder( new Gtk.Label( null ) );
        this.listbox_numeros.row_selected.connect( on_row_numeros_selected );
        this.box_numeros.add ( this.listbox_numeros );
    }

    public void limpiar_listbox_numeros () {
        if ( this.hay_numeros_cargados ) {
            this.botones_borrar_editar_activar ( false );
            this.box_numeros.remove ( this.listbox_numeros );
            this.listbox_numeros = null;
            this.hay_numeros_cargados = false;
        }
    }

    private void agregar_numero_listbox_numeros ( Array<Salva.Entidad> telefonos ) {
        string string_numero = "";
        Gtk.Label label_numero;
        Telefono row_telefono;
        for (int i = 0; i < telefonos.length; i++) {
            row_telefono = telefonos.index (i) as Telefono;
            string_numero = "Numero: %s (%s)".printf ( row_telefono.numero.to_string () , row_telefono.tipo );
            label_numero = new Gtk.Label( string_numero );
            label_numero.set_alignment ( 0, 0);
            this.listbox_numeros.add ( label_numero );
            this.hay_numeros_cargados = true;
        }
    }

    public void crear_dialog_agregar_telefono () {
        guardar_dialog = new TelefonoAgregarDialog ( this.id_contacto_seleccionado );
        guardar_dialog.show ();

        if ( guardar_dialog.run() == ResponseType.APPLY ) {
            stdout.printf ("APPLY");
        }
        guardar_dialog.destroy();
        this.cargar_numeros ( this.id_contacto_seleccionado );
    }

    public void cargar_numeros ( uint contacto_id ) {
        this.id_contacto_seleccionado = contacto_id;
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

    private void on_row_numeros_selected () {
        if ( listbox_numeros.get_selected_row() != null ) {
            this.botones_borrar_editar_activar ( true );
        }
    }

    public void boton_agregar_activar ( bool activar ) {
        numeros_button_agregar.set_sensitive ( activar );
    }

    public void botones_borrar_editar_activar ( bool activar ) {
        numeros_button_editar.set_sensitive ( activar );
        numeros_button_borrar.set_sensitive ( activar );
    }
}
