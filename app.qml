import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    title: "My Application"
    width: 300
    height: 200
    visible: true
    onClosing: Qt.quit()


    RowLayout{
        anchors.fill: parent
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10


        ColumnLayout{
            Slider {
                id: slider1
                Layout.fillHeight: true
                value: observables.sl1_val
                from:0.01
                to:3.0
                stepSize: 0.01
                orientation: Qt.Vertical
                onValueChanged:{
                    observables.sl1_val = value
                }
            }    
            Text {
                id: sl1_text
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: (observables.sl1_val).toFixed(2)
            }
        }

        ColumnLayout {
            Slider {
                id: slider2
                Layout.fillHeight: true
                value: observables.sl2_val
                from:0.01
                to:3.0
                stepSize: 0.01
                orientation: Qt.Vertical
                onValueChanged:{
                    observables.sl2_val = value
                }
            }
            Text {
                id: sl2_text
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: (observables.sl2_val).toFixed(2)
            }
        }    
        ColumnLayout{
            Switch{
                id: sw
                text: "OFF"
                checked: false
                onToggled: {
                    observables.sw_val = checked
                    if (checked){
                        sw.text = "ON "                        
                    } else {
                        sw.text = "OFF"                        
                    }

                }
            }
            RowLayout{
                Text{
                    Layout.leftMargin: 5
                    horizontalAlignment: Text.AlignRight
                    text: "input:"
                }
                ComboBox{
                    Layout.leftMargin: 9
                    model: input_names
                    onActivated: observables.input_name = currentValue
                }
            }
            RowLayout{
                Text {
                    Layout.leftMargin: 5
                    text: "output:"
                }
                ComboBox{
                    model: output_names
                    onActivated: observables.output_name = currentValue
                }
            }
        }
    }
}