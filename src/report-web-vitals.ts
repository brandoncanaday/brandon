import { ReportHandler } from 'web-vitals';

function reportWebVitals(onPerfEntry?: ReportHandler): Promise<boolean> {
    return onPerfEntry && onPerfEntry instanceof Function
        ? import('web-vitals')
              .then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
                  getCLS(onPerfEntry);
                  getFID(onPerfEntry);
                  getFCP(onPerfEntry);
                  getLCP(onPerfEntry);
                  getTTFB(onPerfEntry);
                  return true;
              })
              .catch((error) => {
                  console.error(error);
                  return false;
              })
        : Promise.resolve(false);
}

export default reportWebVitals;
