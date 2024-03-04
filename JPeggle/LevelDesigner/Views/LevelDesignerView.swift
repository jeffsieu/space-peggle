// swiftlint:disable type_body_length
// swiftlint:disable file_length

import SwiftUI

private let hpOptions: [Double] = [10, 50, 100]

struct LevelDesignerView: View {
    @StateObject var controller = LevelDesignerController()
    @State private var levelName = ""
    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var previewRotation: [UUID: Double] = [:]
    @State private var previewScale: [UUID: Vector] = [:]
    @State private var isValidPlacement: [UUID: Bool] = [:]
    @State private var showEmptyError = false
    @State private var showResetConfirmAlert = false
    @State private var showSaveNameDialog = false
    @State private var showDeleteDialog = false
    @State private var customHpValue = ""
    @State private var showHealthBars = true
    @State private var showInvalidLevelAlert = false
    let displayableAdapter = SwiftUISpriteDisplayer()

    private func isModeActive(_ mode: LevelDesignerMode) -> Bool {
        mode == controller.mode
    }

    private var selectedLevel: Level {
        controller.level
    }

    private var isDraggingPeg: Bool {
        !dragOffsets.isEmpty
    }

    private var navigationTitle: String {
        guard controller.savedLevel != nil else {
            return "Untitled level"
        }

        let levelName = selectedLevel.name

        if controller.hasChanges {
            return "\(levelName)*"
        }

        return levelName
    }

    private var secondaryBarStart: ToolbarItemPlacement {
        #if os(OSX)
            .navigationBar
        #else
            .topBarLeading
        #endif
    }

    private var secondaryBarEnd: ToolbarItemPlacement {
        #if os(OSX)
            .navigationBar
        #else
            .topBarTrailing
        #endif
    }

    func createPaletteButton(option: PaletteOption, imageResource: String) -> some View {
        SelectableButton(
            active: isModeActive(.add(option: option)),
            imageResource: imageResource,
            action: {
                controller.toggleAddMode(option: option)
            }
        )
    }

    private var paletteView: some View {
        HStack {
            createPaletteButton(option: .pegBlue, imageResource: "peg-blue")
            createPaletteButton(option: .pegBlueTriangle, imageResource: "peg-blue-triangle")
            createPaletteButton(option: .pegOrange, imageResource: "peg-orange")
            createPaletteButton(option: .pegOrangeTriangle, imageResource: "peg-orange-triangle")
            createPaletteButton(option: .pegGreen, imageResource: "peg-green")
            createPaletteButton(option: .pegGreenTriangle, imageResource: "peg-green-triangle")
            createPaletteButton(option: .pegRed, imageResource: "peg-red")
            createPaletteButton(option: .pegRedTriangle, imageResource: "peg-red-triangle")
            createPaletteButton(option: .block, imageResource: "block")
            Spacer()
            SelectableButton(
                active: isModeActive(.delete),
                imageResource: "delete",
                action: {
                    controller.enterDeleteMode()
                }
            )
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }

    private var boardResizerView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    controller.levelWidth = proxy.size.width
                    controller.levelHeight = proxy.size.height
                }
                .onChange(of: proxy.size) {
                    controller.levelWidth = proxy.size.width
                    controller.levelHeight = proxy.size.height
                }
        }
    }

    private var selectedPegEntity: LevelDesignerEntity? {
        controller.entities.first {
            controller.selectedPegId == $0.id
        }
    }

    private var customHpParsed: Double? {
        let parsed = Double(customHpValue)
        guard let parsed else {
            return nil
        }

        if parsed > 0 {
            return parsed
        }

        return nil
    }

    private var customHpButtonLabel: String {
        if let hp = customHpParsed {
            return "\(Int(hp)) HP"
        }

        if customHpValue.isEmpty {
            return "Custom"
        }

        return "Invalid HP"
    }

    private var selectedItemToolbarView: some View {
        HStack {
            Text("Selected peg HP:")
            Button("No HP") {
                guard let id = controller.selectedPegId else {
                    return
                }
                controller.removeHpFromEntity(withId: id)
            }.disabled(controller.selectedPegId == nil)
            ForEach(hpOptions, id: \.magnitude) { hp in
                Button("\(Int(hp)) HP") {
                    guard let id = controller.selectedPegId else {
                        return
                    }
                    let health = Health(value: hp, max: hp)
                    controller.attachHpToEntity(withId: id, health: health)

                }.disabled(controller.selectedPegId == nil)
            }
            Button(customHpButtonLabel) {
                guard let id = controller.selectedPegId else {
                    return
                }

                guard let customHpParsed else {
                    return
                }

                let health = Health(value: customHpParsed, max: customHpParsed)
                controller.attachHpToEntity(withId: id, health: health)
            }
            .disabled(controller.selectedPegId == nil || customHpParsed == nil)
            TextField("Custom HP value", text: $customHpValue)
            Spacer()
            Toggle("Show health bars", isOn: $showHealthBars)
        }.padding(8).controlSize(.large).buttonStyle(.borderedProminent)
    }

    private var gameAreaView: some View {
        ZStack {
            boardResizerView
            ForEach(controller.entities) { entity in
                let id = entity.id
                let sprite = entity.sprite
                let transform = entity.transform
                let zIndex = entity.zIndex ?? 0
                let health = entity.health
                let scale = previewScale[id] ?? transform.scale

                displayableAdapter.display(sprite)
                    .zIndex(zIndex)
                    .scaleEffect(scale.toCGSize())
                    .rotationEffect(Angle(radians: previewRotation[id] ?? transform.rotation))
                    .position(transform.origin.toCGPoint())
                    .offset(dragOffsets[id] ?? CGSize.zero)
                    .opacity((isValidPlacement[id] ?? true) ? 1.0 : 0.2)
                    .colorMultiply((isValidPlacement[id] ?? true) ? .white : .red)
                    .onTapGesture {
                        controller.tapPeg(withId: id)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0)
                        .onChanged {
                            controller.dragPeg(withId: id)
                            dragOffsets[id] = $0.translation
                            isValidPlacement[id] = controller.canMovePeg(withId: id, offset: $0.translation.toVector())
                        }
                        .onEnded {
                            controller.tryMovePeg(withId: id, offset: $0.translation.toVector())
                            dragOffsets.removeValue(forKey: id)
                            isValidPlacement.removeValue(forKey: id)
                        }
                    )
            }
            ForEach(controller.entities, id: \.id) { entity in
                let sprite = entity.sprite
                let health = entity.health
                let transform = entity.transform
                let scale = previewScale[entity.id] ?? transform.scale

                let dragOffset = dragOffsets[entity.id] ?? CGSize.zero
                let offset = CGSize(
                    width: dragOffset.width,
                    height: dragOffset.height + (-sprite.visualSize.y / 2 * scale.y) - 16
                )

                let showHealthBar = (showHealthBars || entity.id == controller.selectedPegId) && !isDraggingPeg

                if let health, showHealthBar {
                    HealthBar(currentHealth: health.value, maxHealth: health.max)
                        .offset(offset)
                        .position(transform.origin.toCGPoint())
                        .zIndex(10)
                }
            }
        }
        .accessibilityIdentifier("levelDesignerGameArea")
        .background(
            Image("background")
                .resizable()
                .contentShape(Rectangle())
                .allowsHitTesting(false)
        )
        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        .contentShape(Rectangle())
        .clipped()
        .overlay {
            if let selectedPegEntity, !isDraggingPeg {
                let selectedPegId = selectedPegEntity.id
                let sprite = selectedPegEntity.sprite
                let transform = selectedPegEntity.transform
                let canResizeFreely = selectedPegEntity.canResizeFreely

                ResizerView(
                    objectSize: sprite.visualSize.toCGSize(),
                    minScale: 0.5,
                    lockAspectRatio: !canResizeFreely,
                    transform: transform,
                    onPreviewTransformChange: { previewTransform in
                        previewRotation[selectedPegId] = previewTransform.rotation
                        previewScale[selectedPegId] = previewTransform.scale
                        isValidPlacement[selectedPegId] = controller.canTransformPeg(withId: selectedPegId, transform: previewTransform)
                    },
                    onTransformChange: { transform in
                        previewRotation.removeValue(forKey: selectedPegId)
                        previewScale.removeValue(forKey: selectedPegId)
                        isValidPlacement.removeValue(forKey: selectedPegId)
                        controller.tryTransformPeg(withId: selectedPegId, transform: transform)
                    }
                )
                .offset(dragOffsets[selectedPegId] ?? CGSize.zero)
                .zIndex(20)
            }
        }
        .alert("Invalid level", isPresented: $showInvalidLevelAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("Level requires at least one orange peg!")
        }
        .onTapGesture {
            controller.tapPosition(Vector(x: $0.x, y: $0.y))
        }
    }

    private var saveButton: some View {
        Button("Save") {
            guard controller.isLevelCustom else {
                showSaveNameDialog = true
                return
            }

            guard controller.isLevelValid else {
                showInvalidLevelAlert = true
                return
            }
            guard controller.savedLevel != nil else {
                showSaveNameDialog = true
                return
            }
            controller.save()
        }
        .disabled(!controller.isDirty || !controller.isLevelCustom)
    }

    private var saveAsButton: some View {
        Button("Save as") {
            guard controller.isLevelValid else {
                showInvalidLevelAlert = true
                return
            }
            showSaveNameDialog = true
        }.alert("Save as", isPresented: $showSaveNameDialog) {
            TextField("Level name", text: $levelName)
            Button("Save") { controller.saveAsNew(withName: levelName) }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var deleteButton: some View {
        Button("Delete", role: .destructive) {
            showDeleteDialog = true
        }.alert("Delete \"\(controller.level.name)\"?", isPresented: $showDeleteDialog) {
            Button("Delete", role: .destructive) {
                controller.deleteCurrentLevel()
                levelName = ""
            }
            Button("Cancel", role: .cancel) {}
        }.disabled(controller.savedLevel == nil || !controller.isLevelCustom)
    }

    private var loadButton: some View {
        Menu("Load") {
            ForEach(controller.levels, id: \.level.id) { loadedLevel in
                let name = loadedLevel.level.name
                let label = loadedLevel.isPreLoaded ? "Premade: \(name)" : "Custom: \(name)"

                Button(label) {
                    controller.load(levelId: loadedLevel.level.id)
                    levelName = loadedLevel.level.name
                }
            }
        }
        .disabled(controller.levels.isEmpty)
        .alert("Level cannot be loaded", isPresented: $controller.isLevelCorrupted) {}
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: secondaryBarStart) {
            saveButton
            saveAsButton
            deleteButton
            loadButton
        }
        ToolbarItemGroup(placement: secondaryBarEnd) {
            Button("Reset level") { showResetConfirmAlert = true }
                .alert("Reset level?", isPresented: $showResetConfirmAlert) {
                    Button("Reset", role: .destructive) { controller.reset() }
                    Button("Cancel", role: .cancel) {}
                }
        }
        ToolbarItem(placement: .principal) {
            if !controller.isLevelValid {
                Button("Start") {
                    showInvalidLevelAlert = true
                }
            }
            if controller.isLevelValid {
                NavigationLink(destination: GameView(level: controller.level)) {
                    Text("Start")
                }
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                paletteView
                selectedItemToolbarView
                gameAreaView
            }
        }
        .toolbar(content: toolbarContent)
        .navigationTitle(navigationTitle)
        .task {
            await controller.loadInitial()
        }
    }
}

#Preview {
    ZStack {
        LevelDesignerView()
    }.frame(width: 500, height: 400)
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
