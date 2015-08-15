/*
 * contactos-agregar-dialog.vala
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

public class SalvaContactos.ContactoAgregarDialog : Dialog {
    private Gtk.Entry nombre_entry;
    private Gtk.Entry apellido_entry;
    private Gtk.Entry descripcion_entry;
    private Gtk.Widget guardar_boton;
    private ContactoDao contacto_dao;
    public Contacto contacto_por_agregar { public get; public set; }

    public ContactoAgregarDialog () {
        this.title = "Agregar Contacto";
        this.set_modal ( true );
        this.border_width = 5;
        this.set_default_size ( 350, 100 );

        this.crear_widgets ();
        this.conectar_signals ();

        this.contacto_dao = new ContactoDao ( Application.get_base_de_datos () );
    }

    private void crear_widgets () {
        this.nombre_entry = new Gtk.Entry ();
        this.apellido_entry = new Gtk.Entry ();
        this.descripcion_entry = new Gtk.Entry ();

        Gtk.Label nombre_label = new Gtk.Label.with_mnemonic ( "Nombre:" );
        nombre_label.mnemonic_widget = nombre_entry;

        Gtk.Label apellido_label = new Gtk.Label.with_mnemonic ( "Apellido:" );
        apellido_label.mnemonic_widget = apellido_entry;

        Gtk.Label descripcion_label = new Gtk.Label.with_mnemonic ( "Descripcion:" );
        descripcion_label.mnemonic_widget = descripcion_entry;

        Gtk.Box box_labels_inputs = new Gtk.Box ( Orientation.HORIZONTAL, 0 );
        Gtk.Box box_labels = new Gtk.Box ( Orientation.VERTICAL, 0 );
        Gtk.Box box_inputs = new Gtk.Box ( Orientation.VERTICAL, 0 );

        box_labels.pack_start ( nombre_label, true, true, 0 );
        box_inputs.pack_start ( this.nombre_entry, true, true, 0 );

        box_labels.pack_start ( apellido_label, true, true, 0 );
        box_inputs.pack_start ( this.apellido_entry, true, true, 0 );

        box_labels.pack_start ( descripcion_label, true, true, 0 );
        box_inputs.pack_start ( this.descripcion_entry, true, true, 0 );

        box_labels_inputs.pack_start ( box_labels, true, true, 0 );
        box_labels_inputs.pack_start ( box_inputs, true, true, 0 );

        Gtk.Box content = get_content_area () as Gtk.Box;
        content.pack_start ( box_labels_inputs, false, true, 0 );
        content.spacing = 10;

        this.add_button ( "Cerrar", Gtk.ResponseType.CLOSE );
        this.guardar_boton = this.add_button ( "Guardar", Gtk.ResponseType.APPLY );
        this.guardar_boton.sensitive = false;

        this.show_all();
    }

    //TODO revisar varificacion
    private void conectar_signals () {
        this.nombre_entry.changed.connect ( () => {
            this.guardar_boton.sensitive = ( this.nombre_entry.text != "" );
        } );
    this.response.connect ( on_response );
    }

    private void on_response ( Gtk.Dialog source, int response_id ) {
        switch ( response_id ) {
        case Gtk.ResponseType.APPLY:
            this.on_guardar_clicked ();
            break;
        case Gtk.ResponseType.CLOSE:
            this.destroy ();
        break;
        }
    }

    private void on_guardar_clicked () {
        this.contacto_por_agregar = new Contacto.Contacto_sin_id (
            this.nombre_entry.text,
            this.apellido_entry.text,
            this.descripcion_entry.text );
        try {
            this.contacto_dao.insertar ( contacto_por_agregar );
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
    }
}
