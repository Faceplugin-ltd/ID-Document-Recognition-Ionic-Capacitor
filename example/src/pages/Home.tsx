import {
  IonContent,
  IonFooter,
  IonPage,
  IonIcon,
  useIonAlert,
} from '@ionic/react';
import { useHistory } from 'react-router-dom';
import {
  cameraOutline,
  imagesOutline,
  informationCircleOutline,
} from 'ionicons/icons';
import { useSdk } from '../SdkContext';
import FacePluginLogo from '../components/FacePluginLogo';

export default function Home() {
  const { status, ready } = useSdk();
  const history = useHistory();
  const [presentAlert] = useIonAlert();

  const guard = (go: () => void) => {
    if (!ready) {
      presentAlert({ header: 'SDK not ready', message: status, buttons: ['OK'] });
      return;
    }
    go();
  };

  const statusClass = ready
    ? 'status-ok'
    : status.toLowerCase().includes('loading')
      ? 'status-info'
      : 'status-error';

  return (
    <IonPage>
      <IonContent>
        <FacePluginLogo />
        <h1 className="page-title">FacePlugin DocumentReader</h1>

        <div className="tile-grid">
          <div className="tile-row">
            <button
              type="button"
              className={`tile ${ready ? '' : 'disabled'}`}
              onClick={() => guard(() => history.push('/camera'))}
            >
              <IonIcon icon={cameraOutline} className="tile-ionicon" />
              CAMERA
            </button>
            <button
              type="button"
              className={`tile ${ready ? '' : 'disabled'}`}
              onClick={() => guard(() => history.push('/gallery'))}
            >
              <IonIcon icon={imagesOutline} className="tile-ionicon" />
              GALLERY
            </button>
            <button
              type="button"
              className="tile"
              onClick={() => history.push('/about')}
            >
              <IonIcon icon={informationCircleOutline} className="tile-ionicon" />
              ABOUT
            </button>
          </div>
        </div>
      </IonContent>
      <IonFooter className="ion-no-border status-footer">
        <div className={`status-bar ${statusClass}`}>{status}</div>
      </IonFooter>
    </IonPage>
  );
}
