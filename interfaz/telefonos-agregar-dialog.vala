/*
 * telefonos-agregar-dialog.vala
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

public class SalvaContactos.TelefonoAgregarDialog : Dialog {
    private Gtk.Entry numero_entry;
    private Gtk.Entry tipo_entry;
    private Gtk.Widget guardar_boton;
    private TelefonoDao telefono_dao;
    public Telefono telefono_por_agregar { public get; public set; }
    private uint id_contacto_seleccionado;

    public TelefonoAgregarDialog ( uint contacto_id ) {
        this.title = "Agregar Telefono";
        this.set_modal ( true );
        this.border_width = 5;
        this.set_default_size ( 350, 100 );

        this.id_contacto_seleccionado = contacto_id;

        this.crear_widgets ();
        this.conectar_signals ();

        this.telefono_dao = new TelefonoDao ( Application.get_base_de_datos () );
    }

    private void crear_widgets () {
        this.numero_entry = new Gtk.Entry ();
        this.tipo_entry = new Gtk.Entry ();

        Gtk.Label numero_label = new Gtk.Label.with_mnemonic ( "Numero:" );
        numero_label.mnemonic_widget = numero_entry;

        Gtk.Label tipo_label = new Gtk.Label.with_mnemonic ( "Tipo:" );
        tipo_label.mnemonic_widget = tipo_entry;

        Gtk.Box box_labels_inputs = new Gtk.Box ( Orientation.HORIZONTAL, 0 );
        Gtk.Box box_labels = new Gtk.Box ( Orientation.VERTICAL, 0 );
        Gtk.Box box_inputs = new Gtk.Box ( Orientation.VERTICAL, 0 );

        box_labels.pack_start ( numero_label, true, true, 0 );
        box_inputs.pack_start ( this.numero_entry, true, true, 0 );

        box_labels.pack_start ( tipo_label, true, true, 0 );
        box_inputs.pack_start ( this.tipo_entry, true, true, 0 );

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
        this.numero_entry.changed.connect ( () => {
            this.guardar_boton.sensitive = ( this.numero_entry.text != "" );
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
        this.telefono_por_agregar = new Telefono.Telefono_sin_id (
            int.parse ( this.numero_entry.text ),
            this.tipo_entry.text,
            this.id_contacto_seleccionado );
        try {
            this.telefono_dao.insertar ( telefono_por_agregar );
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
    }
}
