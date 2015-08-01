/*
 * contactos-editar-dialog.vala
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

public class SalvaContactos.ContactoEditarDialog : Dialog {
    private Gtk.Entry nombre_entry;
    private Gtk.Entry apellido_entry;
    private Gtk.Entry descripcion_entry;
    private Gtk.TreeSelection seleccionado;
    private uint id_contacto_seleccionado;
    private Gtk.Widget guardar_boton;
    private ContactoDao contacto_dao;
    public Contacto contacto_por_editar { public get; public set; }

    public ContactoEditarDialog ( Gtk.TreeSelection seleccionado ) {
        this.title = "Editar Contacto";
        this.set_modal ( true );
        this.border_width = 5;
        set_default_size ( 350, 100 );

        this.seleccionado = seleccionado;
        this.crear_widgets ();
        this.conectar_signals ();
        this.cargar_contacto ();

        this.contacto_dao = new ContactoDao ();
        this.contacto_dao.set_db ( new Salva.BaseDeDatos ( Application.db_nombre ) );
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
        this.contacto_por_editar = new Contacto (
            this.id_contacto_seleccionado,
            this.nombre_entry.text,
            this.apellido_entry.text,
            this.descripcion_entry.text );

        this.contacto_dao.actualizar ( contacto_por_editar );
    }

    private void cargar_contacto () {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        uint id;
        string nombre;
        string apellido;
        string descripcion;

        if (this.seleccionado.get_selected (out model, out iter)) {
            model.get (iter, ListStoreContactos.COLUMNAS.ID, out id);
            model.get (iter, ListStoreContactos.COLUMNAS.NOMBRE, out nombre);
            model.get (iter, ListStoreContactos.COLUMNAS.APELLIDO, out apellido);
            model.get (iter, ListStoreContactos.COLUMNAS.DESCRIPCION, out descripcion);
            this.id_contacto_seleccionado = id;
            this.nombre_entry.text = nombre;
            this.apellido_entry.text = apellido;
            this.descripcion_entry.text = descripcion;
        }
    }
}
