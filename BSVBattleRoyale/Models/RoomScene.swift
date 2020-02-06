//
//  RoomScene.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit


protocol RoomSceneDelegate: AnyObject {
	func player(_ currentPlayer: Player, enteredDoor: DoorSprite)
}

class RoomScene: SKScene {

	var otherPlayers = [String: Player]()

	let background = RoomSprite()
	var currentPlayer: Player?
	var liveController: LiveConnectionController?
	weak var roomDelegate: RoomSceneDelegate?

	private lazy var fadeSprite: SKSpriteNode = {
		let sp = SKSpriteNode(color: .black, size: self.size)
		self.camera?.addChild(sp)
		sp.alpha = 0
		return sp
	}()

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		setupScene()
	}

	func setupScene() {
		addChild(background)

		physicsWorld.gravity = CGVector.zero
		physicsWorld.contactDelegate = self
	}

	func loadRoom(room: Room?, playerPosition: CGPoint, playerID: String) {
		background.room = room

		let newPlayer = Player(avatar: .yellowMonster, id: playerID)
		newPlayer.position = CGPoint.zero
		addChild(newPlayer)
		currentPlayer = newPlayer
		newPlayer.zPosition = 1
		newPlayer.position = playerPosition

		let playerCamera = SKCameraNode()
		newPlayer.addChild(playerCamera)
		camera = playerCamera
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)

			currentPlayer?.move(to: location, duration: -250)
		}
	}

	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)

		// send player position
		guard let player = currentPlayer else { return }
		liveController?.updatePlayerPosition(player.position)
	}

	func updateOtherPlayers(updatePlayers: [String: OtherPlayerUpdate]) {
		guard let currentPlayer = currentPlayer else { return }
		var newPlayers = updatePlayers
		var expiredPlayers = [Player]()
		// dont track current player
		newPlayers[currentPlayer.id] = nil

		for (id, updatedPlayer) in otherPlayers {
			guard let update = updatePlayers[id] else {
				// if this player isn't in this update, mark them as expired
				expiredPlayers.append(updatedPlayer)
				continue
			}
			// update any other consistent player's position
			updatedPlayer.move(to: update.position, duration: 1/60)
			// unmark this player as a new player
			newPlayers[id] = nil
		}

		// add all new players to the scene and track them
		for (id, newPlayer) in newPlayers {
			let addtlPlayer = Player(avatar: .yellowMonster, id: id)
			addChild(addtlPlayer)
			otherPlayers[id] = addtlPlayer
			addtlPlayer.position = newPlayer.position
		}

		// remove expired players
		for delete in expiredPlayers {
			otherPlayers[delete.id] = nil
			delete.removeFromParent()
		}
	}
}

extension RoomScene: SKPhysicsContactDelegate {

	func didBegin(_ contact: SKPhysicsContact) {
		var bodies = Set([contact.bodyB, contact.bodyA])
		var physicNodes = Set(bodies.compactMap { $0.node })

		if let currentPlayer = currentPlayer {
			if physicNodes.contains(currentPlayer) && physicNodes.contains(background) {
				currentPlayer.stopMove()
			}

			// one of the nodes is player
			if physicNodes.remove(currentPlayer) != nil {
				if let door = physicNodes.removeFirst() as? DoorSprite {
					currentPlayer.physicsBody = nil
					let action = SKAction.fadeIn(withDuration: 0.1)
					fadeSprite.run(action)
					roomDelegate?.player(currentPlayer, enteredDoor: door)
				}
			}
		}
	}
}
