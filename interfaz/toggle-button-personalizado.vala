/*
 * contacto.vala
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
using Gtk;
using SalvaContactos;

 public class SalvaContactos.ToggleButtonPersonalizado : Gtk.ToggleButton {
    public bool estaba_activo { public get; public set; }
    public bool cambio_de_estado { public get; public set; }

    public ToggleButtonPersonalizado.with_label ( string label ) {
        Object ( label: label );
        this.estaba_activo = false;
        this.cambio_de_estado = false;
    }

    public void cambiar_estado () {
        this.cambio_de_estado = !this.cambio_de_estado;
    }
 }
