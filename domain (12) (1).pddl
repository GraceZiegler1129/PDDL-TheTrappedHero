(define (domain Dungeon)

    (:requirements :typing :negative-preconditions
    )

    (:types
        swords cells
    )

    (:predicates
        ;Hero's cell location
        (at-hero ?loc - cells)

        ;Sword cell location
        (at-sword ?s - swords ?loc - cells)

        ;Indicates if a cell location has a monster
        (has-monster ?loc - cells)

        ;Indicates if a cell location has a trap
        (has-trap ?loc - cells)

        ;Indicates if a chell or sword has been destroyed
        (is-destroyed ?obj)

        ;connects cells
        (connected ?from ?to - cells)

        ;Hero's hand is free
        (arm-free)

        ;Hero's holding a sword
        (holding ?s - swords)

        ;It becomes true when a trap is disarmed
        (trap-disarmed ?loc - cells)

    )

    ;Hero can move if the
    ;    - hero is at current location
    ;    - cells are connected, 
    ;    - there is no trap in current loc, and 
    ;    - destination does not have a trap/monster/has-been-destroyed
    ;Effects move the hero, and destroy the original cell. No need to destroy the sword.
    (:action move
        :parameters (?from ?to - cells)
        :precondition (and (at-hero ?from)
            (connected ?from ?to) ;cells are connected
            (not (has-trap ?from))
            (not (has-trap ?to));current location doesnt have trap
            (not (has-monster ?to)) ;destination doesnt have monster
            (not (is-destroyed ?to))) ;destination isnt destroyed

        :effect (and (not (at-hero ?from)) ;leaves current cell
            (at-hero ?to) ;hero at destination cell
            (is-destroyed ?from) ;previous cell destroyed    
        )

    )

    ;When this action is executed, the hero gets into a location with a trap
    (:action move-to-trap
        :parameters (?from ?to - cells)
        :precondition (and (at-hero ?from)
            (connected ?from ?to) ;current cell and destination cell are connected
            (not (is-destroyed ?to)) ;destination cell not destroyed
            (has-trap ?to);(has-trap ?to) ;destination cell has a trap 
            (not (has-monster ?to))
            (arm-free) ;hero is not holding a sword
            (not (has-trap ?from))
        )
        :effect (and (not (at-hero ?from)) ;hero is no longer at previous cell
            (at-hero ?to) ;hero is at destination cell
            (has-trap ?to)
            (is-destroyed ?from) ;previous cell destroyed
        )

    )

    ;When this action is executed, the hero gets into a location with a monster
    (:action move-to-monster
        :parameters (?from ?to - cells ?s - swords)
        :precondition (and (at-hero ?from)
            (connected ?from ?to) ;cells are connected
            (not (is-destroyed ?to))
            (not (has-trap ?to));destinationcell not destroyed
            (holding ?s)
            (not (has-trap ?from))
        )

        :effect (and (not (at-hero ?from)) ;hero no longer at previous cell
            (at-hero ?to)
            (holding ?s)
            (has-monster ?to);hero at destination cell
            (is-destroyed ?from)) ;previous cell is destroyed

    )

    ;Hero picks a sword if he's in the same location
    (:action pick-sword
        :parameters (?loc - cells ?s - swords)
        :precondition (and (at-hero ?loc) ;hero is at particular cell 
            (at-sword ?s ?loc) ;there is a sword at the particular cell
            (arm-free) ;the hero is not holding anything
            (not (has-trap ?loc))

        )
        :effect (and (at-hero ?loc)
            (holding ?s) ;hero picks up sword   
            (not (arm-free))
        )
    )

    ;Hero destroys his sword. 
    (:action destroy-sword
        :parameters (?loc - cells ?s - swords)
        :precondition (and (at-hero ?loc) ;hero is at cell location
            (holding ?s) ;hes holding a sword
            (not (has-monster ?loc)); cell doesnt have trap or monster
            (not (has-trap ?loc))
        )
        :effect (and (at-hero ?loc)
            (is-destroyed ?s) ;hero destroys sword  
            (arm-free)
        )
    )

    ;Hero disarms the trap with his free arm
    (:action disarm-trap
        :parameters (?loc - cells)
        :precondition (and (at-hero ?loc) ;hero is at particular cell
            (arm-free) ;hero is not holding anything
            (has-trap ?loc) ;cell has a trap
        )
        :effect (and (at-hero ?loc)
            (trap-disarmed ?loc) ;trap is disarmed
            (not (has-trap ?loc))
        )
    )

)