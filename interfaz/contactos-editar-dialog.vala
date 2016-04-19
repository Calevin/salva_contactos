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
    private TagDao tag_dao;
    public Contacto contacto_por_editar { public get; public set; }
    private ToggleButtonPersonalizado toogle_button_tag_familia;
    private ToggleButtonPersonalizado toogle_button_tag_amigos;
    private ToggleButtonPersonalizado toogle_button_tag_trabajo;
    private ToggleButtonPersonalizado toogle_button_tag_estudio;
    private Array<Salva.Entidad> tags_actuales;

    enum TAGS {
        NINGUNO,
        FAMILIA,
        TRABAJO,
        AMIGOS,
        ESTUDIO,
        N_TAGS
    }

    public ContactoEditarDialog ( Gtk.TreeSelection seleccionado ) {
        this.title = "Editar Contacto";
        this.set_modal ( true );
        this.border_width = 5;
        set_default_size ( 350, 100 );

        this.contacto_dao = new ContactoDao ( Application.get_base_de_datos () );
        this.tag_dao = new TagDao ( Application.get_base_de_datos () );

        this.seleccionado = seleccionado;
        this.crear_widgets ();
        this.cargar_contacto ();
        this.cargar_tags_del_contacto ();
        this.setear_estado_botones_toggle ();
        this.conectar_signals ();
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

        Gtk.Box box_tags = new Gtk.Box ( Orientation.HORIZONTAL, 0 );

        this.toogle_button_tag_familia = new ToggleButtonPersonalizado.with_label ("Familia");
        this.toogle_button_tag_trabajo = new ToggleButtonPersonalizado.with_label ("Trabajo");
        this.toogle_button_tag_amigos = new ToggleButtonPersonalizado.with_label ("Amigos");
        this.toogle_button_tag_estudio = new ToggleButtonPersonalizado.with_label ("Estudio");

        box_tags.pack_start (this.toogle_button_tag_familia, true, true, 0 );
        box_tags.pack_start (this.toogle_button_tag_amigos, true, true, 0 );
        box_tags.pack_start (this.toogle_button_tag_trabajo, true, true, 0 );
        box_tags.pack_start (this.toogle_button_tag_estudio, true, true, 0 );

        Gtk.Box content = get_content_area () as Gtk.Box;
        content.pack_start ( box_labels_inputs, false, true, 0 );
        content.pack_start ( box_tags, false, true, 0 );
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
    this.toogle_button_tag_familia.toggled.connect ( this.toogle_button_tag_familia.cambiar_estado );
    this.toogle_button_tag_amigos.toggled.connect ( this.toogle_button_tag_amigos.cambiar_estado );
    this.toogle_button_tag_trabajo.toggled.connect ( this.toogle_button_tag_trabajo.cambiar_estado );
    this.toogle_button_tag_estudio.toggled.connect ( this.toogle_button_tag_estudio.cambiar_estado );
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
        try {
            this.contacto_dao.actualizar ( contacto_por_editar );
            this.actualizar_estado_de_los_tags ();
        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
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

    private void cargar_tags_del_contacto () {
        try {
            this.tags_actuales = this.contacto_dao.
                                                get_entidades_relacionadas ( new Contacto.Contacto_id (this.id_contacto_seleccionado), this.tag_dao );

        } catch ( BaseDeDatosError e ) {
            stderr.printf ( "ERROR: %s", e.message );
        }
    }

    private void setear_estado_botones_toggle () {
        Tag tag;
        for (int i = 0; i < this.tags_actuales.length; i++) {
            tag = this.tags_actuales.index (i) as Tag;
            switch (tag.id) {
                case TAGS.FAMILIA:
                    toogle_button_tag_familia.set_active (true);
                    toogle_button_tag_familia.estaba_activo = true;
                break;
                case TAGS.TRABAJO:
                    toogle_button_tag_trabajo.set_active (true);
                    toogle_button_tag_trabajo.estaba_activo = true;
                break;
                case TAGS.AMIGOS:
                    toogle_button_tag_amigos.set_active (true);
                    toogle_button_tag_amigos.estaba_activo = true;
                break;
                case TAGS.ESTUDIO:
                    toogle_button_tag_estudio.set_active (true);
                    toogle_button_tag_estudio.estaba_activo = true;
                break;
            }
        }
    }

    private void actualizar_estado_de_los_tags () throws BaseDeDatosError {
        actualizar_estado_tag ( toogle_button_tag_familia, TAGS.FAMILIA);
        actualizar_estado_tag ( toogle_button_tag_trabajo, TAGS.TRABAJO);
        actualizar_estado_tag ( toogle_button_tag_amigos, TAGS.AMIGOS);
        actualizar_estado_tag ( toogle_button_tag_estudio, TAGS.ESTUDIO);
    }

    private void actualizar_estado_tag (ToggleButtonPersonalizado toogle_button_tag, uint tag_id) throws BaseDeDatosError {
        Contacto contacto_seleccionado = new Contacto.Contacto_id (this.id_contacto_seleccionado);
        Tag tag = new Tag.Tag_id ( tag_id );

        if ( toogle_button_tag.cambio_de_estado ) {
            if ( toogle_button_tag.estaba_activo ) {
                //Si cambio de estado y estaba activo, el tag fue borrado del contacto
                this.contacto_dao.borrar_relacion ( contacto_seleccionado, tag, this.tag_dao );
            } else {
                //Si cambio de estado y antes NO estaba activo, el tag fue agregado al contacto
                this.contacto_dao.guardar_relacion ( contacto_seleccionado, tag, this.tag_dao );
            }
        }
    }
}
