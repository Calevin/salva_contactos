/*
 * salva-contactos-application.vala
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

public class SalvaContactos.Application : Gtk.Application {
    private Gtk.HeaderBar headerbar;
    private Gtk.Button headerbar_button_agregar;
    private Gtk.Button headerbar_button_borrar;
    private Gtk.Button headerbar_button_editar;
    private ContactoAgregarDialog guardar_dialog;
    private ContactoEditarDialog editar_dialog;
    private Gtk.TreeView view;
    private ListStoreContactos list_store_contactos;
    private TelefonosBox telefonos_box;

    enum TOOLBAR_ITEMS {
        NUEVO,
        BORRAR,
        EDITAR,
        N_ITEMS
    }

    public static string db_nombre = "./persistencia/salva_contactos.db";

    public Application () {
        Object(application_id: "salva.contactos.application",
            flags: ApplicationFlags.FLAGS_NONE );
    }

    protected override void activate () {
        Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
        window.set_default_size (400, 400);
        window.window_position = Gtk.WindowPosition.CENTER;
        window.set_titlebar ( this.crear_headerbar () );

        Gtk.Paned paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.add1 ( this.crear_treeview_contactos () );
        telefonos_box = this.crear_telefonosbox ();
        paned.add2 ( telefonos_box.box_numeros );

        window.add ( paned );

        window.show_all ();
    }

    private Gtk.HeaderBar crear_headerbar () {
        this.headerbar = new Gtk.HeaderBar ();
        headerbar.set_show_close_button (true);
        headerbar.set_title ("Salva Contactos");
        headerbar.set_subtitle ("Contactos");

        this.headerbar_button_agregar = new Gtk.Button.from_icon_name ( "contact-new", Gtk.IconSize.SMALL_TOOLBAR );
        this.headerbar_button_agregar.clicked.connect ( this.crear_dialog_agregar_contacto );
        headerbar.add ( this.headerbar_button_agregar );

        this.headerbar_button_borrar = new Gtk.Button.from_icon_name ( "edit-delete", Gtk.IconSize.SMALL_TOOLBAR );
        headerbar_button_borrar.clicked.connect (() => {
            list_store_contactos.borrar_contacto_seleccionado ();
        });
        headerbar_button_borrar.set_sensitive ( false );
        headerbar.add ( headerbar_button_borrar );

        this.headerbar_button_editar = new Gtk.Button.from_icon_name ( "accessories-text-editor", Gtk.IconSize.SMALL_TOOLBAR  );
        headerbar_button_editar.clicked.connect ( this.crear_dialog_editar_contacto );
        headerbar_button_editar.set_sensitive ( false );
        headerbar.add ( headerbar_button_editar );

        return headerbar;
    }

    private Gtk.TreeView crear_treeview_contactos () {
        list_store_contactos = new ListStoreContactos ();
        view = new Gtk.TreeView.with_model ( list_store_contactos );
        Gtk.CellRendererText cell = new Gtk.CellRendererText ();
        int inserted_at_the_end = -1;

        //Columna "invisible" ID
        Gtk.TreeViewColumn id_columna_invisible = new Gtk.TreeViewColumn ();
        id_columna_invisible.set_visible (false);
        id_columna_invisible.set_expand (false);
        id_columna_invisible.set_clickable (false);
        view.insert_column ( id_columna_invisible , 0);
        //Columnas visibles
        view.insert_column_with_attributes ( inserted_at_the_end, "Nombre", cell, "text", 1 );
        view.insert_column_with_attributes ( inserted_at_the_end, "Apellido", cell, "text", 2 );
        view.insert_column_with_attributes ( inserted_at_the_end, "Descripcion", cell, "text", 3 );

        list_store_contactos.seleccionado = view.get_selection ();
        list_store_contactos.seleccionado.changed.connect ( this.seleccionado_on_changed );

        return view;
    }

    private TelefonosBox crear_telefonosbox () {
        telefonos_box = new TelefonosBox ();
        return telefonos_box;
    }

    public void crear_dialog_agregar_contacto () {
            guardar_dialog = new ContactoAgregarDialog ();
            guardar_dialog.show ();

            if ( guardar_dialog.run() == ResponseType.APPLY ) {
                this.list_store_contactos.recargar_liststore ();
            }
            guardar_dialog.destroy();
            list_store_contactos.seleccionado.unselect_all ();
            this.headerbar_borrar_editar_activar ( false );
            this.telefonos_box.limpiar_listbox_numeros ();
    }

    public void crear_dialog_editar_contacto () {
            editar_dialog = new ContactoEditarDialog ( list_store_contactos.seleccionado );
            editar_dialog.show ();

            if ( editar_dialog.run() == ResponseType.APPLY ) {
                this.list_store_contactos.recargar_liststore ();
            }
            editar_dialog.destroy();
            list_store_contactos.seleccionado.unselect_all ();
            this.headerbar_borrar_editar_activar ( false );
            this.telefonos_box.limpiar_listbox_numeros ();
    }

    public void seleccionado_on_changed () {
        list_store_contactos.seleccionar_contacto ( list_store_contactos.seleccionado );
        this.headerbar_borrar_editar_activar ( true );
        this.telefonos_box.cargar_numeros ( list_store_contactos.id_contacto_seleccionado );
    }

    private void headerbar_borrar_editar_activar (bool activar) {
        this.headerbar_button_borrar.set_sensitive ( activar );
        this.headerbar_button_editar.set_sensitive ( activar );
    }
}
