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
    private Gtk.TreeView view;
    private ListStoreTelefonos list_store_telefonos;
    private uint id_contacto_seleccionado;
    private TelefonoAgregarDialog guardar_dialog;
    private TelefonoEditarDialog editar_dialog;

    public TelefonosBox ( uint id_contacto_seleccionado ) {
        this.box_numeros = new Gtk.Box ( Gtk.Orientation.VERTICAL, 0 );
        this.box_numeros.add ( new Gtk.Label ( "Numeros" ) );
        this.box_numeros.add ( new Gtk.Separator ( Gtk.Orientation.HORIZONTAL ));

        this.id_contacto_seleccionado = id_contacto_seleccionado;
        this.box_numeros.add ( this.crear_treeview_telefonos () );

        Gtk.Box secondary_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);

        numeros_button_agregar = new Gtk.Button.from_icon_name ("list-add", Gtk.IconSize.SMALL_TOOLBAR);
        numeros_button_agregar.clicked.connect ( this.crear_dialog_agregar_telefono );
        numeros_button_agregar.set_sensitive ( false );
        secondary_box.pack_start ( numeros_button_agregar );
        numeros_button_editar = new Gtk.Button.with_label  ("Editar");
        numeros_button_editar.clicked.connect ( this.crear_dialog_editar_telefono );
        numeros_button_editar.set_sensitive ( false );
        secondary_box.pack_start ( numeros_button_editar );
        numeros_button_borrar = new Gtk.Button.from_icon_name ("list-remove", Gtk.IconSize.SMALL_TOOLBAR);
        numeros_button_borrar.clicked.connect (() => {
            list_store_telefonos.borrar_telefono_seleccionado ();
        });
        secondary_box.pack_start ( numeros_button_borrar );
        numeros_button_borrar.set_sensitive ( false );

        this.box_numeros.pack_end ( secondary_box ,false );
    }

    public void recargar_telefonos ( uint id_contacto_seleccionado ) {
        this.id_contacto_seleccionado = id_contacto_seleccionado;
        list_store_telefonos.id_contacto_seleccionado = id_contacto_seleccionado;
        list_store_telefonos.recargar_liststore ( );
    }

    private Gtk.TreeView crear_treeview_telefonos () {
        list_store_telefonos = new ListStoreTelefonos ( this.id_contacto_seleccionado );
        view = new Gtk.TreeView.with_model ( list_store_telefonos );
        Gtk.CellRendererText cell = new Gtk.CellRendererText ();
        int inserted_at_the_end = -1;

        //Columna "invisible" ID
        Gtk.TreeViewColumn id_columna_invisible = new Gtk.TreeViewColumn ();
        id_columna_invisible.set_visible (false);
        id_columna_invisible.set_expand (false);
        id_columna_invisible.set_clickable (false);
        view.insert_column ( id_columna_invisible , 0);
        //Columnas visibles
        view.insert_column_with_attributes ( inserted_at_the_end, "Numero", cell, "text", 1 );
        view.insert_column_with_attributes ( inserted_at_the_end, "Tipo", cell, "text", 2 );

        list_store_telefonos.seleccionado = view.get_selection ();
        list_store_telefonos.seleccionado.changed.connect ( this.seleccionado_on_changed );

        return view;
    }

    public void crear_dialog_agregar_telefono () {
        guardar_dialog = new TelefonoAgregarDialog ( this.id_contacto_seleccionado );
        guardar_dialog.show ();

        if ( guardar_dialog.run() == ResponseType.APPLY ) {
            this.list_store_telefonos.recargar_liststore ();
        }
        guardar_dialog.destroy();
        list_store_telefonos.seleccionado.unselect_all ();
        this.botones_borrar_editar_activar ( false );
    }

    public void crear_dialog_editar_telefono () {
            editar_dialog = new TelefonoEditarDialog (
                list_store_telefonos.seleccionado,
                this.id_contacto_seleccionado);
            editar_dialog.show ();

            if ( editar_dialog.run() == ResponseType.APPLY ) {
                this.list_store_telefonos.recargar_liststore ();
            }
            editar_dialog.destroy();
            list_store_telefonos.seleccionado.unselect_all ();
            this.botones_borrar_editar_activar ( false );
    }

    public void seleccionado_on_changed () {
        list_store_telefonos.seleccionar_telefono ( list_store_telefonos.seleccionado );
        this.botones_borrar_editar_activar ( true );
    }

    public void boton_agregar_activar ( bool activar ) {
        numeros_button_agregar.set_sensitive ( activar );
    }

    public void botones_borrar_editar_activar ( bool activar ) {
        numeros_button_editar.set_sensitive ( activar );
        numeros_button_borrar.set_sensitive ( activar );
    }
}
