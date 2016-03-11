import sys
import traceback

from PyQt4 import QtGui
from PyQt4 import QtCore
from PyQt4.QtCore import Qt

import aaf

from qt_aafmodel import AAFModel

import clip_menu

class GraphicsTimeSlider(QtGui.QGraphicsRectItem):


    def __init__(self,parent=None):
        super(GraphicsTimeSlider,self).__init__(parent)

        #self.setFlag(QtGui.QGraphicsItem.ItemIsSelectable,True)

        self.height = 100
        self.edge_spacing = 10

        pen = QtGui.QPen()
        pen.setBrush(Qt.blue)
        self.setPen(pen)
        self.setBrush(Qt.blue)
        self.frame = 0
        self.setZValue(100)
        self.setPos(0,0)


    def setHeight(self,value):
        self.height = value

        self.adjust()

    def setFrame(self,value):

        self.frame = int(value)
        self.adjust()

        #print "frame =", self.frame
    def getFrame(self):
        return self.frame

    def adjust(self):

        rect = QtCore.QRectF(0,0,1,self.height)

        rect.adjust(0,-self.edge_spacing,0,self.edge_spacing)
        self.setRect(rect)
        self.setPos(self.frame, 0)

class GraphicsClip(QtGui.QGraphicsRectItem):

    def __init__(self,length, parent=None):
        super(GraphicsClip,self).__init__(parent)

        self.length = length

        self.track = None
        self.left = None
        self.right = None
        self.name = None

        self._reference = None

        self.setFlag(QtGui.QGraphicsItem.ItemIsSelectable,True)

    def getReference(self):
        return self._reference

    def adjust(self):

        height = self.track.height

        self.setRect(QtCore.QRectF(0,0, self.length, height))

        y = self.track.y()
        x = 0

        if self.left:
            x = self.left.x() + self.left.length
        self.setPos(x,y)

    def paint(self,p,opt,w):

        super(GraphicsClip,self).paint(p,opt,w)

        if self.name:
            p.save()
            nameRect = QtCore.QRectF(self.rect())
            #setCosmetic(True)
            p.pen().setCosmetic(True)
            p.drawText(nameRect,Qt.AlignLeft,self.name)
            p.restore()

    def contextMenuEvent(self, contextEvent):
        reload(clip_menu)
        clip_menu.clip_menu(contextEvent, self)

class GraphicsClipTransition(GraphicsClip):
    def __init__(self,length, parent=None):
        super(GraphicsClipTransition,self).__init__(length, parent)
        self.cutpoint = 0

    def paint(self,p,opt,w):

        super(GraphicsClipTransition,self).paint(p,opt,w)
        p.save()
        rect = self.rect()
        p.drawLine(rect.bottomLeft(), rect.topRight())
        p.drawLine(rect.bottomLeft() + QtCore.QPointF(self.cutpoint, 0),
                   rect.topLeft() + QtCore.QPointF(self.cutpoint, 0),)

        p.restore()


class GraphicsTrack(QtGui.QGraphicsRectItem):

    def __init__(self,parent=None):

        super(GraphicsTrack,self).__init__(parent)

        self.height = 20
        self.length = 0
        self.name = "Track"
        self._reference = None

        self.timeline = None

        self.parent = None

        self.clips = []



    def addClip(self,length,reference=None, transtion=False):

        if transtion:
            clip = GraphicsClipTransition(length)
            clip.cutpoint = reference.cutpoint
        else:
            clip = GraphicsClip(length)
        clip.track = self
        clip._reference = reference

        if self.clips:

            prev_clip = self.clips[-1]
            prev_clip.right = clip

            clip.left = prev_clip

        scene = self.scene()
        scene.addItem(clip)

        self.clips.append(clip)

        clip.adjust()

        self.length += length
        self.adjust()

        return clip



    def adjust(self):
        self.setRect(QtCore.QRectF(0,0,self.length,self.height))

        spacing = self.timeline.track_spacing


        if self.parent:
            y = self.parent.y()
            self.setY(y + self.parent.height + spacing)

        for clip in self.clips:
            clip.adjust()

class AAFTimeline(QtGui.QGraphicsScene):

    def __init__(self,parent=None):

        super(AAFTimeline,self).__init__(parent)

        self.tracks = []
        self.track_spacing = 10
        self.edge_spacing = 50
        self.timeSlider = None

        self.timeSliderDrag = False

    def addTrack(self):

        track = GraphicsTrack()
        track.timeline = self
        if self.tracks:
            track.parent = self.tracks[-1]

            track.adjust()
        self.tracks.append(track)
        self.addItem(track)

        self.updateSceneRect()
        return track

    def updateSceneRect(self):

        rect = QtCore.QRectF()
        for track in self.tracks:
            rect = rect.united(track.sceneBoundingRect())

        height = rect.height()
        rect.adjust(0,-self.edge_spacing,0,self.edge_spacing)
        self.setSceneRect(rect)

        self.timeSlider.edge_spacing = self.edge_spacing
        self.timeSlider.setHeight(height)

    def setFrame(self,value):
        self.timeSlider.setFrame(value)

    def getFrame(self):
        return self.timeSlider.getFrame()

    def clear(self):

        super(AAFTimeline,self).clear()

        self.tracks = []

        self.timeSlider = GraphicsTimeSlider()
        self.timeSlider.edge_space = self.edge_spacing
        self.timeSlider.setPos(0,0)

        self.addItem(self.timeSlider)

    def adjustHeight(self, value):
        for track in self.tracks:
            track.height += value
            track.adjust()

        self.updateSceneRect()


class AAFTimelineGraphicsView(QtGui.QGraphicsView):

    def __init__(self,parent=None):

        super(AAFTimelineGraphicsView,self).__init__(parent)
        self.timeSliderDrag = False
        #self.setViewportUpdateMode(QtGui.QGraphicsView.FullViewportUpdate)

        self.marginWidth = 90
        self.topMaginHeight = 35

        self.setViewportMargins(self.marginWidth, self.topMaginHeight, 0, 0)

        self.timelineWidget = TimeLineWidget(self)
        self.timelineWidget.frameChanged.connect(self.setCurrentFrame)
        self.timelineWidget.snap.connect(self.snapToNearest)
        self.frameSpinbox = QtGui.QSpinBox(self)

        self.frameSpinbox.setFixedSize(self.marginWidth-3,self.topMaginHeight-3)
        self.frameSpinbox.setRange(-1000000,10000000)

        self.frameSpinbox.valueChanged.connect(self.setCurrentFrame)
        self.trackWidgets = []


    def updateTrackLabels(self,offset=0):
        scene = self.scene()
        edge = self.mapToScene(0,0)

        for track in self.trackWidgets:
            track.hide()

        for i, track in enumerate(scene.tracks):
            rect = track.rect()
            pos = track.pos()
            widget_pos = self.mapFromScene(pos)
            widget_height =  self.mapFromScene(rect.bottomLeft()).y() - self.mapFromScene(rect.topLeft()).y()

            if i+1 > len(self.trackWidgets):
                l = QtGui.QLabel(self)
                l.setFrameStyle(QtGui.QFrame.Panel)
                self.trackWidgets.append(l)

            label = self.trackWidgets[i]

            label.show()
            label.move(0,widget_pos.y() + self.topMaginHeight)

            label.setText(track.name)

            label.setFixedWidth(self.marginWidth)
            label.setFixedHeight(widget_height + 2)
        self.frameSpinbox.raise_()

    def markIn(self,value):
        print "markIn", value
        self.timelineWidget.markIn(value)
    def markOut(self,value):
        print "markOut", value
        self.timelineWidget.markOut(value)
    def clearMarks(self):
        print "clear marks"
        self.timelineWidget.clearMarks()

    def setCurrentFrame(self,value):

        scene = self.scene()
        if scene:
            scene.setFrame(value)
            self.updateTimeLine()

            sliderRect = QtCore.QRectF(scene.timeSlider.sceneBoundingRect())

            y = self.verticalScrollBar().value()
            self.ensureVisible(sliderRect)
            self.verticalScrollBar().setValue(y) #Don't change the Y Scroll
            self.frameSpinbox.setValue(int(value))
            self.repaint()
    def currentFrame(self):
        scene = self.scene()
        if scene:
            return scene.getFrame()


    def updateTimeLine(self):

        t = self.timelineWidget

        t.move(QtCore.QPoint(self.marginWidth,0))

        t.setFixedWidth(self.viewport().width())
        t.setFixedHeight(self.topMaginHeight)


        scene = self.scene()
        if scene:
            t.setScale(self.transform().m11())
            #print t.scale

            t.start = self.mapToScene(0,0).x()
            t.setCurrentFrame(self.currentFrame())
            #t.end = self.mapToScene(self.width() - self.m, self.topMaginHeight).x()
            t.repaint()
    def snapToNearest(self,radius = 50):

        pos = self.mapFromScene(self.currentFrame(), 0)
        item = self.nearestItemAt(pos,radius)

        if item:
            self.setCurrentFrame(item.pos().x())


    def nearestItemAt(self,pos,radius = 50):

        scene = self.scene()

        sceneRect = scene.sceneRect()

        top = self.mapFromScene(sceneRect.topLeft()).y()
        bottom = self.mapFromScene(sceneRect.bottomRight()).y()

        rect = QtCore.QRect(pos.x() - radius, top,pos.x() + radius, bottom)
        rectF = QtCore.QRectF(rect)

        nearest = None

        scenePos = self.mapToScene(pos)

        min_x = self.mapToScene(pos.x() - radius, 0).x()
        max_x = self.mapToScene(pos.x() + radius, 0).x()

        rectF = QtCore.QRectF(min_x, sceneRect.top(),
                            max_x, sceneRect.bottom())

        last_item = None
        last_distance = None

        for item in scene.items(rectF,mode=Qt.IntersectsItemBoundingRect):

            if isinstance(item, GraphicsClip):
                itemX = item.pos().x()
                if itemX > min_x and itemX < max_x:
                    distance = abs(scenePos.x() - itemX)
                    if last_item is None:
                        last_item = item
                        last_distance = distance

                    else:
                        if distance < last_distance:
                            last_item = item
                            last_distance = distance

        return last_item


    def paintEvent(self, event):
        #self.updateTrackLabels()
        result = super(AAFTimelineGraphicsView,self).paintEvent(event)
        self.updateTrackLabels()
        self.updateTimeLine()

    def mousePressEvent(self,event):
        pos = event.pos()
        scenePos = self.mapToScene(pos)
        print "scene",scenePos
        scene = self.scene()

        if scene:
            if not scene.itemAt(scenePos):
                self.setCurrentFrame(scenePos.x())
                self.timeSliderDrag = True

                if event.modifiers() == Qt.ControlModifier:
                    self.snapToNearest()
                event.accept()


        super(AAFTimelineGraphicsView,self).mousePressEvent(event)

    def mouseMoveEvent(self, event):
        pos = event.pos()
        scenePos = self.mapToScene(pos)

        scene = self.scene()
        if self.timeSliderDrag:
            self.setCurrentFrame(scenePos.x())


            if event.modifiers() == Qt.ControlModifier:
                self.snapToNearest()



        super(AAFTimelineGraphicsView,self).mouseMoveEvent(event)

    def mouseReleaseEvent(self,event):
        if self.timeSliderDrag:
            self.timeSliderDrag = False

        super(AAFTimelineGraphicsView,self).mouseReleaseEvent(event)


    def wheelEvent(self, event):

        if event.modifiers() == Qt.AltModifier:
            self.setTransformationAnchor(QtGui.QGraphicsView.AnchorUnderMouse)
            scaleFactorX = 1.15
            scaleFactorY = 1

            if event.delta() > 0:

                self.scale(scaleFactorX, 1)
            else:
                self.scale(1.0 / scaleFactorX, 1)
        else:
            super(AAFTimelineGraphicsView,self).wheelEvent(event)

    def zoom(self, value):
        self.setTransformationAnchor(QtGui.QGraphicsView.AnchorViewCenter)
        scaleFactorX = 1.15

        #transform = self.transform()


        if value > 0:
            self.scale(scaleFactorX, 1)
        else:
            self.scale(1.0 / scaleFactorX, 1)

    def keyPressEvent(self, event):

        scene = self.scene()

        if scene:
            if event.key() == Qt.Key_F:
                mode=Qt.KeepAspectRatioByExpanding
                if event.modifiers() == Qt.ShiftModifier:
                    mode = Qt.IgnoreAspectRatio
                self.fitInView(scene.sceneRect(),mode=mode)

            elif event.modifiers() == Qt.ControlModifier:
                if event.key() == Qt.Key_L:
                    scene.adjustHeight(2)

                elif event.key() == Qt.Key_K:
                    scene.adjustHeight(-2)

                elif event.key() == Qt.Key_BracketLeft:
                    self.zoom(-1)

                elif event.key() == Qt.Key_BracketRight:
                    self.zoom(1)

            elif event.key() == Qt.Key_Right:
                self.setCurrentFrame(self.currentFrame() + 1)

            elif event.key() == Qt.Key_Left:
                self.setCurrentFrame(self.currentFrame() - 1)

            elif event.key() == Qt.Key_I:
                self.markIn(self.currentFrame())

            elif event.key() == Qt.Key_O:
                self.markOut(self.currentFrame())

            elif event.key() == Qt.Key_G:
                self.clearMarks()
            else:
                super(AAFTimelineGraphicsView,self).keyPressEvent(event)


        else:
            super(AAFTimelineGraphicsView,self).keyPressEvent(event)

class TimeLineWidget(QtGui.QWidget):
    frameChanged = QtCore.pyqtSignal(int)
    snap = QtCore.pyqtSignal(int)
    def __init__(self,parent):

        super(TimeLineWidget,self).__init__(parent)

        fps = 24
        self.start = 0
        self.end = 1
        self.scale = 1
        self.snapRadius = 50
        self.currentFrame = 10
        self.silderDrag = True
        self.fps = fps
        self.steps = (1,2,3,int(fps/4), int(fps/2), fps,fps*2, fps*30, fps*30*5,fps*30*15,fps*30*30,fps*30*60)
        self.mark_in = None
        self.mark_out = None

    def markIn(self,value):
        self.mark_in= value
        self.repaint()
    def markOut(self,value):
        self.mark_out = value
        self.repaint()

    def clearMarks(self):
        self.mark_in = None
        self.mark_out = None
        self.repaint()

    def setCurrentFrame(self,value):

        self.currentFrame = int(value)
        self.repaint()

    def setScale(self,value):
        self.scale = value
        self.end = (self.width() / self.scale) + self.start

    def setEnd(self, value):

        self.end = value
        self.scale = self.length() / self.width()

    def length(self):

        return self.end - self.start

    def mapFromFrame(self,value):

        return (float(value) - self.start)  * self.scale

    def mapToFrame(self, value):

        frame = (value/ float(self.width()) * self.length()) + self.start
        return int(frame)

    def mousePressEvent(self, event):

        frame = self.mapToFrame(event.pos().x())
        self.setCurrentFrame(frame)
        self.silderDrag = True
        self.frameChanged.emit(frame)
        if event.modifiers() == Qt.ControlModifier:
            self.snap.emit(self.snapRadius)

        super(TimeLineWidget,self).mousePressEvent(event)
    def mouseMoveEvent(self, event):

        if self.silderDrag:
            frame = self.mapToFrame(event.pos().x())
            self.setCurrentFrame(frame)
            self.frameChanged.emit(frame)
            if event.modifiers() == Qt.ControlModifier:
                self.snap.emit(self.snapRadius)
        super(TimeLineWidget,self).mouseMoveEvent(event)

    def mouseReleaseEvent(self,event):

        if self.silderDrag:
            self.silderDrag = False



        super(TimeLineWidget,self).mouseMoveEvent(event)


    def paintEvent(self, event):
        super(TimeLineWidget,self).paintEvent(event)

        painter =QtGui.QPainter()
        painter.begin(self)
        #painter.setBrush(Qt.black)

        rect = self.rect()
        rect.adjust(0,0,0,-2)

        painter.drawRect(rect)

        #paint timeslider
        rect = QtCore.QRectF(0,0,1.0 * self.scale,self.height())
        rect.translate(self.mapFromFrame(self.currentFrame), 0)
        pen =QtGui.QPen(Qt.blue)
        painter.setPen(pen)
        painter.setBrush(Qt.blue)
        painter.drawRect(rect)

        #paint marks
        painter.setPen(QtGui.QPen(Qt.black))
        painter.setBrush(Qt.NoBrush)

        fm = QtGui.QFontMetricsF(painter.font())

        #draw markin
        if not self.mark_in is None:
            painter.save()
            height = self.height() * .4
            x = self.mapFromFrame(self.mark_in)

            char = ']'
            font_width = fm.width(char)

            painter.drawText(QtCore.QPointF(x-font_width,height),char)
            painter.restore()

        #draw markout
        if not self.mark_out is None:
            painter.save()
            height = self.height() * .4
            x = self.mapFromFrame(self.mark_out)
            char = '['
            #font_width = fm.width(char)

            painter.drawText(QtCore.QPointF(x,height),char)

            painter.restore()

        #draw selection
        if not self.mark_in is None and not self.mark_out is None:
            painter.save()
            selection_rect = QtCore.QRectF(0, 0,
                                           (self.mark_out - self.mark_in)*self.scale, self.height())

            selection_rect.translate(self.mapFromFrame(self.mark_in), 0)

            color = QtGui.QColor(Qt.blue)
            color.setAlphaF(.4)
            brush = QtGui.QBrush(color)
            painter.setBrush(brush)
            painter.setPen(QtGui.QPen(color))
            painter.drawRect(selection_rect)
            painter.restore()




        length = self.length()
        last_tick = 0
        last_text = -90

        step = 1

        fps = self.fps
        #find a optimized step
        #this should be adjusted of different frame rates
        for step in self.steps:
            if self.width() / length * step > 5:
                break

        start = int(round(self.start/step) * step) #start at a multple of step

        for i in xrange(start, int(self.end), step):
            x = self.mapFromFrame(i)

            if x - last_tick > 5:
                last_tick = x
                height_ratio = .7

                if i % (step * 2) == 0:
                    height_ratio = .5

                painter.drawLine(x, self.height() * height_ratio, x, self.height()-4)


            if i & 1 == 0: #text for only even numbers
                if int(round(i/step) * step) == i: #only multiples of step

                    if x - last_text > 100:
                        last_text = x
                        height = self.height() * .4
                        painter.drawText(QtCore.QPointF(x,height), str(i))


        painter.end()



def AddMobFromIndex(index,grahicsview):
    treeItem = index.internalPointer()
    mob = treeItem.item
    if isinstance(mob, aaf.mob.Mob):
        SetMob(mob,grahicsview)


def get_tracks(mob,trackType= 'Picture'):
    tracks = []

    for slot in mob.slots():
        segment = slot.segment

        if segment.media_kind == trackType:
            if isinstance(segment, aaf.component.NestedScope):

                for nested_segment in segment.segments():

                    if isinstance(nested_segment, aaf.component.Sequence):
                        tracks.append(nested_segment)


            elif isinstance(segment, aaf.component.Sequence):
                tracks.append(segment)

            elif isinstance(segment, aaf.component.SourceClip):
                tracks.append([segment])

            elif isinstance(segment, aaf.component.Selector):
                tracks.append([segment.selected])

            elif isinstance(segment, aaf.component.EssenceGroup):
                #choices = []
                #for c in xrange(segment.CountChoices()):
                    #choices.append(segment.GetChoiceAt(c))
                tracks.append([segment])
    return tracks

def get_transition_offset(index,component_list):

    offset = 0

    nextItem = None
    prevousItem = None

    if len(component_list) > index + 1:
        nextItem = component_list[index + 1]

    if index != 0:
        prevousItem = component_list[index -1]

    if isinstance(nextItem, aaf.component.Transition):
        offset -= nextItem.length - nextItem.cutpoint

    if isinstance(prevousItem, aaf.component.Transition):
        offset -= prevousItem.cutpoint

    return offset

def get_source_clip_name(item):

    ref = item.resolve_ref()
    if ref:
        if ref.name:
            return ref.name

    for clip in item.walk():
        ref = clip.resolve_ref()
        if ref:
            if ref.name:
                return ref.name

    return "SourceClip"


def get_operation_group_name(item):

    operation_name = item.operation
    for segment in item.input_segments():

        if isinstance(segment, aaf.component.SourceClip):
            name = get_source_clip_name(segment)
            if name:
                return "%s(%s)" % (name,operation_name)

        else:
            for component in segment.components():
                #print component
                if isinstance(component, aaf.component.SourceClip):
                    name = get_source_clip_name(component)
                    if name:
                        return "%s(%s)" % (name,operation_name)

def get_selector_name(item):
    segment = item.selected

    if isinstance(segment, aaf.component.SourceClip):
        return get_source_clip_name(segment)

    elif isinstance(segment, aaf.component.Sequence):
         for component in segment.components():
             if isinstance(component, aaf.component.SourceClip):
                 return get_source_clip_name(component)


    return "Selector"

def SetMob(mob,grahicsview):

    scene = grahicsview.scene()

    scene.clear()

    video_tracks = get_tracks(mob)
    last_clip = None
    for track_num, segment in reversed(list(enumerate(video_tracks))):
        track = scene.addTrack()
        track.name = "Track V%i" % (track_num+1)
        track._reference = video_tracks[track_num]
        length = 0

        if isinstance(segment, list):
            components = segment
        else:
            components = segment.components()

        for i,component in enumerate(components):

            color =Qt.red
            transtion = False
            if isinstance(component,aaf.component.Transition):
                last_clip.length -= component.length
                track.length -= component.length
                last_clip.adjust()
                color = Qt.yellow
                transtion = True
                #continue


            transition_offset = 0
            if last_clip:
                if isinstance(last_clip._reference, aaf.component.Transition):
                    transition_offset = last_clip._reference.length - last_clip._reference.cutpoint
                    transition_offset = last_clip._reference.length

                    #print component, component.cutpoint, component.length
                #continue

            #if not isinstance(component,aaf.component.Transition):

            #transition_offset = get_transition_offset(i,components)

            component_length = component.length - transition_offset
            clip = track.addClip(component_length,component, transtion)


            last_clip = clip
            #make filler and scope grey

            name = None

            if isinstance(component,(aaf.component.Filler, aaf.component.ScopeReference)):
                color = Qt.gray

            elif isinstance(component, aaf.component.SourceClip):
                name = get_source_clip_name(component)

            elif isinstance(component, aaf.component.OperationGroup):
                color = Qt.magenta
                #segment = component.GetInputSegmentAt(0)
                name = get_operation_group_name(component)
                if not name:
                    name = component.operation

            if isinstance(component, aaf.component.Selector):
                name = get_selector_name(component)
                color - Qt.darkYellow


            clip.setBrush(color)

            if name:
                clip.name = name
                clip.adjust()

            length += component_length


    scene.updateSceneRect()
if __name__ == "__main__":




    from optparse import OptionParser

    parser = OptionParser()
    (options, args) = parser.parse_args()

    if not args:
        parser.error("not enough arguments")

    file_path = args[0]

    f = aaf.open(file_path)

    app = QtGui.QApplication(sys.argv)

    window = QtGui.QSplitter()

    #layout = QtGui.QHBoxLayout()

    header = f.header
    storage = f.storage

    topLevelMobs = list(storage.toplevel_mobs())

    model = AAFModel(storage)

    timeline = AAFTimeline()

    tree = QtGui.QTreeView()
    tree.setModel(model)
    tree.resize(650,600)
    tree.expandToDepth(0)
    tree.resizeColumnToContents(0)



    graphicsview = AAFTimelineGraphicsView()
    graphicsview.resize(400,600)
    graphicsview.setScene(timeline)

    tree.doubleClicked.connect(lambda x,y=graphicsview: AddMobFromIndex(x,y))

    if topLevelMobs:
        SetMob(topLevelMobs[0],graphicsview)
    window.addWidget(tree)
    window.addWidget(graphicsview)

    window.resize(900,600)

        #window.setLayout(layout)

    window.show()
    #graphicsview.show()

    sys.exit(app.exec_())
