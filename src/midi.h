/*
 * This file is part of midi16.
 *
 * midi16 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * midi16 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with midi16. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MIDI_H
#define MIDI_H

/* MIDI Header structure. */
typedef struct
{
    /* "MThd" */
    char id[4];
    /* Chunk size (BE dword) */
    uint8_t size[4];
    /* Format type (BE word) */
    uint8_t type[2];
    /* Number of tracks (BE word) */
    uint8_t tracks[2];
    /* Time division (BE word) */
    uint8_t time_div[2];

} midi_header_t;

/* MIDI Track Chunk structure. */
typedef struct
{
    /* "MTrk" */
    char id[4];
    /* Chunk size (BE dword) */
    uint8_t size[4];

} midi_track_t;

/* MIDI Event structure. */
typedef struct
{
    

} midi_event_t;

/* MIDI File structure. */
typedef struct
{
    midi_header_t *header;
    midi_track_t **tracks;
    midi_event_t **events;

} midi_file_t;



#endif
